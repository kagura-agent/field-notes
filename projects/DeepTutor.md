# DeepTutor

- **Repo**: HKUDS/DeepTutor
- **语言**: Python (FastAPI + LiteLLM)
- **领域**: AI tutoring system with RAG

## PR History

### PR #267 — Enable streaming for tool-calling (2026-04-08)
- **Issue**: #265 — 百炼 Coding Plan endpoint tool calling InvalidParameter
- **修复**: `litellm_provider.py` stream=True for tool-calling + `_collect_stream()` helper
- **Target**: `dev` branch（CONTRIBUTING.md 要求所有 PR target dev）
- **CI**: 全绿（Python 3.11 + 3.12）
- **状态**: pending review

## 架构演进 (v1.0.0, 2026-04-04)

**重大重写** — 从 RAG 学习工具升级为 agent-native 平台：
- **两层插件模型**: Tools (底层能力) + Capabilities (高层组合) — 类似 OpenClaw 的 skill 分层
- **TutorBot**: 自治 tutor agent，各有独立 workspace/memory/personality，基于 nanobot 框架
- **5 模式统一 workspace**: Chat / Deep Solve / Quiz / Deep Research / Math Animator 共享上下文
- **SKILL.md 对外暴露**: 其他 agent 可通过 SKILL.md 自主操作 DeepTutor — 与 AgentSkills 理念一致
- **Persistent Memory**: 跨 session 的学习者画像，用于 personalization
- **CLI-first**: 结构化 JSON 输出，方便 agent pipeline 集成
- **移除 litellm**: beta.3 改用 native OpenAI/Anthropic SDK（我们的 PR #267 是 litellm 时代的）

**与我们的关联**:
- SKILL.md 互操作: DeepTutor 已是 AgentSkills 兼容的 — OpenClaw agent 可直接调用
- 两层插件设计和我们的 skill 理念相似，可参考
- 我们的 PR #267 (litellm streaming) 可能因 litellm 移除而失效，需检查

## 项目笔记

- **维护者友好**: #263 快速 merge + 感谢回复，响应速度快
- **pre-commit**: 项目配了 pre-commit hooks，是必需的；本地因网络问题没跑通（ruff 下载失败），但 CI 会跑
- **百炼 Coding Plan endpoint**: 不支持 non-streaming tool calling（返回 InvalidParameter），必须用 stream=True
- **贡献流程**: fork → dev branch → PR to upstream dev
