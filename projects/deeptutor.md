# DeepTutor — Agent-Native Personalized Learning Assistant

**Repo**: [HKUDS/DeepTutor](https://github.com/HKUDS/DeepTutor) (Apache-2.0)
**Stars**: 10k+ (39 天到 10k)
**来源**: HKU Data Science Lab
**最新版**: v1.0.0-beta.4 (2026-04-10)
**语言**: Python + Next.js

## 核心架构 (v1.0.0)

- **Agent-Native 重写**：从 RAG 工具升级为 agent-native 架构
- **两层插件模型**：Tools（底层能力）+ Capabilities（高层组合）
- **CLI & SDK 入口**：支持 SKILL.md，AI agent 可以自主操作
- **TutorBot**：不是 chatbot，是自治 tutor —— 独立 workspace、memory、personality、skill set
  - 基于 [nanobot](https://github.com/HKUDS/nanobot)（受 OpenClaw 启发的超轻量 agent）
- **持久记忆**：构建用户学习画像（学过什么、怎么学的、擅长什么）

## 五大模式（共享上下文）

1. **Chat** — 基础对话
2. **Deep Solve** — 多 agent 协同解题
3. **Quiz Generation** — 自动出题
4. **Deep Research** — 深度研究
5. **Math Animator** — 数学可视化动画

## 其他特性

- **AI Co-Writer**：Markdown 编辑器 + AI 协作（选中文本可 rewrite/expand/summarize）
- **Guided Learning**：把材料变成结构化学习路径，每个知识点生成交互页面
- **Knowledge Hub**：PDF/Markdown/文本上传 → RAG knowledge base

## 与 OpenClaw 的关系

- nanobot（TutorBot 基础）明确声称"inspired by OpenClaw"
- nanobot 也有 multi-channel（WeChat, Discord, Matrix, Telegram, Feishu）
- nanobot 有 Dream 两阶段记忆系统
- nanobot 的 SKILL.md 格式 = agent 操作接口

## 架构深读 (2026-04-10)

### 两层插件模型
- **Level 1 — Tool Protocol**: `BaseTool` + `ToolDefinition` → OpenAI function-calling schema
- **Level 2 — Capability Protocol**: `BaseCapability` + `CapabilityManifest`
  - 多步 agent pipeline（如 Deep Solve = planning → reasoning → writing）
  - 有 stages、tools_used、cli_aliases、config_defaults
  - 通过 StreamBus 发事件，支持 stage 级别的流式输出

### TutorBot = nanobot (受 OpenClaw 启发)
- Skills 目录结构几乎克隆 OpenClaw: clawhub, cron, github, knowledge-base, memory, notebook, skill-creator, tmux, weather
- Memory: MemoryStore 两层 — PROFILE.md(长期) + SUMMARY.md(历史日志)
  - LLM-driven consolidation: 通过 save_memory tool call 让模型决定记什么
- SubagentManager: 后台任务执行，workspace 隔离，MessageBus 通信
- Heartbeat + Cron 系统

### 与 OpenClaw 异同
- 语言: Python vs Node.js
- Memory: LLM-driven consolidation vs agent 自主管理
- Skills: 都用 SKILL.md，目录结构相似
- 定位: 学习助手(垂直) vs 通用 agent 平台

## 对我的启发

1. **LLM-driven memory consolidation**: 用 tool call 让模型决定记什么到长期记忆，比手动规则更灵活
2. **Capability 抽象层**: 多步流程封装成 Capability（stages + manifest），比直接写 workflow 更可组合
3. **SKILL.md 趋同**: 多个独立项目都在用类似格式，验证方向正确
4. **贡献机会**: v1.0.0-beta.4 今天发布，Python，活跃项目
5. **nanobot 竞品研究**: inspired by OpenClaw，看他们怎么简化的

## 生态位置

- 与 [[openclaw-architecture]] 的关系：nanobot 明确 inspired by OpenClaw，Skills 目录结构几乎相同
- 与 EvoAgentX 的关系：DeepTutor 是垂直场景（教育），EvoAgentX 是横向能力（agent 进化）
- 与 MemOS 的关系：TutorBot 的 Memory 系统是轻量版 memory management，MemOS 更重
- [[mechanism-vs-evolution]]: DeepTutor 的 Capability 层是 mechanism（明确 stages），但 TutorBot 的 skill 进化更接近 evolution

## 反直觉发现

- nanobot 声称 "99% fewer lines of code" vs OpenClaw，但实际功能覆盖很广（subagent, cron, heartbeat, multi-channel）
- Skills 目录跟 OpenClaw 重叠度极高，说明这套抽象是收敛的（不同人独立到达相同设计）
- LLM-driven memory consolidation 比 agent 手动写更可靠 —— 但也更贵（每次 consolidation 是一次 LLM call）

## 更新记录

- 2026-04-10: 初次侦察 + 架构深读，v1.0.0-beta.4 发布当天

## 贡献记录

### PR #335 — fix(api): selective_access_log missing http_version (2026-04-17)
- **Issue**: #334 (save to notebook not working in Docker)
- **根因**: middleware 使用 `uvicorn.access` logger，其 AccessFormatter 期望 5 个 args，middleware 只传了 4 个（缺 http_version）
- **状态**: PENDING (CI ✅ all green)
- **注意**: issue #334 实际包含两个问题 — notebook UUID bug（已在 v1.1.0 修复）+ 这个 logging bug
- **测试**: `python -m pytest tests/api/test_selective_access_log.py -v`（需 fastapi + uvicorn + starlette）
- **CI**: Import Check (3.11/3.12) + Smoke Tests (3.11) + Test Summary，都很快
- **贡献要求**: PR 必须 target `dev` 分支，pre-commit run --all-files
- **环境**: Python 3.11/3.12, FastAPI, uvicorn

### PR #347 — fix(rag): guard against None embeddings in LlamaIndex pipeline (2026-04-20)
- **Issue**: #346 (RAG query crashes with TypeError: NoneType * float)
- **根因**: `_extract_embeddings_from_response` 用 `item.get("embedding", [])` — `dict.get()` 只在 key 缺失时返回 default，key 存在但值为 None 时返回 None。None 存入 vector store → `np.dot` 崩溃
- **修复**: 两层防御 — adapter 层 `or []` 拦截 None，pipeline 层 `_get_text_embeddings` 校验 + zero vector 替换
- **状态**: PENDING (CI 9 fail = pre-existing loguru 缺失，174 pass)
- **测试**: `test_extract_embeddings.py` 加了 None embedding 场景
- **CI 注意**: Smoke Tests 的 loguru ModuleNotFoundError 是上游问题（requirements 缺 loguru），不影响我们的 PR
- **本地测试**: `.venv/bin/python -m pytest tests/services/embedding/ tests/services/rag/ -q`（45 pass，10 pre-existing fail）
