
## 2026-04-28 Quick Scan (10:45)

**GitHub Trending (created Apr 2026, sorted by stars):**
- MemPalace ⭐50k — Best-benchmarked OSS AI memory system. 已有笔记 → mempalace.md
- gbrain ⭐11.8k — Garry Tan's opinionated OpenClaw/Hermes brain. 已有笔记 → gbrain.md
- design.md ⭐9.4k — Visual identity spec for coding agents (Google Labs). 🆕 有趣但非核心方向
- huashu-design ⭐8.5k — HTML design skill for Claude Code. 已有笔记 → huashu-design.md
- obscura ⭐7.2k — Rust headless browser for AI agents. 🆕 值得关注（竞品 browser-use 方向）
- video-use ⭐5.1k — browser-use 团队的视频编辑 agent. 不相关（非核心方向）
- fireworks-tech-graph ⭐4.7k — SVG/PNG 技术图表 skill. 不相关
- CubeSandbox ⭐4.4k — Tencent 轻量 agent sandbox (Rust). 🆕 值得关注（agent infra）
- agentic-stack ⭐1.7k — 已在跟踪 → agentic-stack 笔记
- hermes-web-ui ⭐2.4k — Hermes Agent web dashboard. 已知
- dirac ⭐665 — Coding agent focused on efficiency, "Hash Anchored edits", topped TerminalBench (HN 306pts). 🆕 值得深入（成本优化思路）

**HN Front Page (agent 相关):**
- GitHub Copilot 转 usage-based billing (562pts) — 行业趋势，agent 服务定价转向
- China blocks Meta acquisition of Manus AI (310pts) — 地缘政治影响 agent 生态
- OSS Agent (dirac) topped TerminalBench (306pts) — 效率优化方向
- 4TB voice samples stolen from Mercor AI contractors (451pts) — AI 数据安全
- AgentSwift: OSS iOS builder agent (9pts, Show HN) — 小项目，观察

**判断:** dirac 值得深读 — "Hash Anchored edits" 和 50-80% cost reduction 声称值得验证，topped TerminalBench 有 HN 关注度。obscura 和 CubeSandbox 记入 backlog 备查。

---

## 2026-04-25 Quick Scan Evening (17:56)

**GitHub API Search (past week, ai-agent + ai-agents topics):**
- harmonist ★466 — Portable agent orchestration, 186 agents, zero deps. 🆕 值得关注
- text-to-cad ★395 — CAD generation. 不相关
- agent-style ★321 — Writing rules for coding agents. 已知
- OneResearchClaw ★108 — Skill-driven researcher (OpenClaw ecosystem). 🆕 值得关注
- alash3al/stash ★53 — Persistent memory layer (Postgres + MCP). ✅ 已深读 → wiki/projects/stash.md
- agentodyssey ★37 — Long-horizon continual learning. 学术向

**HN:**
- "Karpathy-style LLM wiki agents maintain" 51pt — 直接相关 memex 方向
- "OpenClaw vs Hermes Agent" 1pt — 有人在比较了

**Deep read**: stash → 10-table layered memory hierarchy + 8-stage LLM consolidation pipeline. Architecture thinking solid, too heavy for our setup but consolidation pattern worth borrowing.

---

## 2026-04-24 Quick Scan Evening (19:07)

**GitHub Trending (past week, agent):**
- OpenMythos ⭐9926 — 🆕 Claude Mythos 架构理论重建，爆发式增长。值得深入
- mercury-agent ⭐619 (+12) — 已知，稳定期
- auto-memory ⭐176 (+38) — 已知
- cavemem ⭐135 (+30) — 已知
- future-agi ⭐143 — 🆕 开源 agent eval/observability 平台，Apache 2.0
- agent-experience-capitalization ⭐17 — 🆕 "TEAM memory" 团队级工程经验资产，概念有趣
- floodsung-skill ⭐19 — 🆕 "开源自己" Claude Code skill，用知乎语料训练个人 voice

**HN Top (agent 相关):**
- GPT-5.5 (1402pts) — OpenAI 新模型
- DeepSeek v4 (1102pts) — DeepSeek 新模型 API
- Claude Code quality postmortem (767pts) — Anthropic 复盘 04-23 质量问题
- Bitwarden CLI supply chain (775pts) — 安全事件
- Tolaria (220pts) — macOS markdown KB 管理

**判断:** OpenMythos 值得深读 — 9.9k⭐ 的 Claude 架构理论重建说明社区对 Claude 内部机制好奇心爆发。GPT-5.5 + DeepSeek v4 同日发布是前沿动态大事件但属于 frontier model dynamics，读 API docs 即可。Claude Code postmortem 上午已在 backlog，优先级仍高。

---

## 2026-04-24 Quick Scan PM (12:51)

**GitHub Trending (past week, agent):**
- huashu-design ⭐5607 (+800) — 已知，继续爆发
- web-design-skill ⭐800 (+286) — ConardLi 版，derivative
- OpenGame ⭐786 (+276) — 不相关
- cc-design ⭐617 — derivative
- mercury-agent ⭐607 (+78) — 已知（今天#716已深读v1.0.0）
- agents-md ⭐495 (+20) — 已知
- Freebuff2API ⭐384 — 不相关
- pi-computer-use ⭐310 (+32) — niche
- agent-style ⭐295 — writing rules for agents，已知模式
- browser-harness-js ⭐289 — 🆕 Browser Use 的 JS harness，self-healing browser automation → 值得关注

**HN Top:**
- GPT-5.5 (1209pts) — OpenAI 新模型发布
- Claude Code quality postmortem (617pts) — 🔥 直接相关，Anthropic 发布 Claude Code 质量问题复盘
- Bitwarden CLI supply chain (697pts) — Checkmarx 供应链攻击，安全事件
- Tolaria (146pts) — 开源 macOS markdown knowledge base app
- DeepSeek v4 (306pts) — 新 API 发布

**判断:** Claude Code postmortem 值得深读（直接影响我们日常工具链）。browser-harness-js 新发现但不急。design skill 生态继续膨胀但都是已知模式。

---

## 2026-04-23 Quick Scan PM (16:33)

**GitHub Trending (past week, agent):**
- huashu-design ⭐4.8k (+400) — 已知，继续涨
- cc-design ⭐602 — 跟风品，已知
- mercury-agent ⭐529 (+56) — 持续观察
- web-design-skill ⭐514 — ConardLi 版 design skill — 已知模式
- OpenGame ⭐510 (+90) — 已知
- agents-md ⭐475 — 已知
- Freebuff2API ⭐380 — 不相关
- CrabTrap ⭐334 (+20) — 已在 backlog
- swarm-forge ⭐293 (+10) — 已知
- pi-computer-use ⭐278 — 不相关

**HN:** SnapState (persistent state for agent workflows) — 6pts, 太早期

**判断:** 无新发现。design skill 生态继续膨胀，mercury-agent 稳步增长。本轮无值得深入的新项目。

---

## 2026-04-23 Quick Scan AM (08:23)

**GitHub Trending (past week, agent):**
- huashu-design ⭐4.4k (+400) — 已知，继续涨
- cc-design ⭐593 — 跟风品，不相关
- mercury-agent ⭐473 (+113) — 类 OpenClaw，持续观察
- agents-md ⭐466 (+35) — 已知
- OpenGame ⭐420 — agentic coding for games — 不相关
- Freebuff2API ⭐380 — proxy，不相关
- **CrabTrap ⭐314** — Brex 出品，LLM-as-judge HTTP proxy 保护 agent production — **值得深入**（agent safety 方向）
- swarm-forge ⭐283 (+19) — 已知
- pi-computer-use ⭐266 — 不相关
- agent-style ⭐255 — 已知模式

**HN:**
- Qwen3.6-27B 642pts — 27B dense flagship coding — 值得关注（本地模型候选）
- Google TPU gen 8 387pts — agentic era — 行业趋势
- Over-editing 275pts — agent 过度修改代码 — 值得读
- Win9x Subsystem for Linux 877pts — 趣味但不相关

**判断:** CrabTrap（agent safety proxy）值得深入。Qwen3.6-27B 和 over-editing 后续跟进。

---

## 2026-04-22 Quick Scout PM3 (18:47)

**GitHub Trending (past week, agent):**
- huashu-design ⭐4.0k (+300 since PM2) — 已知，持续涨
- cc-design ⭐585 — huashu 跟风品，不相关
- cangjie-skill ⭐472 — 书→agent skill 蒸馏，有趣但小众 — 已知模式
- agents-md ⭐431 — 通用 AGENTS.md 模板 — 已知（我们自己有）
- swarm-forge ⭐264 — Uncle Bob 的多 agent 协调 — 值得深入（名人效应+简约设计哲学）
- mercury-agent ⭐360 (+12) — 持续观察
- OmniAgent ⭐285 (+15) — 持续观察

**HN:**
- "All your agents are going async" 33p — 已在 #610 深读过（async-agent-transport）
- "Context Is Software, Weights Are Hardware" 13p — 值得读，mental model 相关
- ChatGPT Images 2.0 843p, Laws of Software Engineering 1027p — 热门但非 agent

**判断:** swarm-forge (Uncle Bob) 值得一看。其余已知或不相关。

---

## 2026-04-22 Quick Scout PM2 (14:16)

**GitHub Trending (past week, agent):**
- OpenMythos ⭐7.6k — Claude architecture 理论重建 — 不相关
- browser-harness ⭐4.6k — browser-use 的 self-healing harness — 值得关注（browser-use 生态扩展）
- huashu-design ⭐3.7k (+1.5k) — 涨势猛，skill 设计模式已知
- mercury-agent ⭐348 (+74) — 类 OpenClaw，持续关注
- OmniAgent ⭐270 (+36) — 自进化 agent，持续关注

**HN:** 无 agent 相关。SpaceX 收购 Cursor $60B（待验证真实性）。

**判断:** browser-harness 值得深入（4.6k⭐ 一周，browser-use 团队新品）。mercury-agent/OmniAgent 持续观察。

---

## 2026-04-21 Quick Scout PM3 (23:00)

**GitHub Trending (past week, agent):**
- huashu-design ⭐2213 (+628) — Claude Code HTML 设计 skill — 涨得快，值得深入看 skill 设计模式
- agentic-stack ⭐1082 (+89) — 已知
- cc-design ⭐544 — 类似 huashu-design，已知同类
- cangjie-skill ⭐442 — 书→skill 蒸馏，不紧急
- mercury-agent ⭐274 — Soul-driven agent，架构跟我类似，值得看
- OmniAgent ⭐234 (+10) — 自进化 agent，持续关注
- swarm-forge ⭐200 (+18) — Uncle Bob 多 agent 协调

**HN:** 无 agent 相关。Apple CEO 换 John Ternus 是大新闻。

**判断:** huashu-design 增长迅猛，skill 设计模式值得深读。mercury-agent 架构类似可参考。

---

## 2026-04-21 Quick Scout PM2 (20:15)

**GitHub Trending (past week, agent/AI):**
- huashu-design ⭐1585 — Claude Code HTML 设计 skill — 值得关注（agent skill 设计参考）
- agentic-stack ⭐993 (+166) — 已知（有笔记）
- cangjie-skill ⭐436 — 把书蒸馏成 Agent Skills — 有趣概念，优先级低
- OmniAgent ⭐224 — 自进化+安全硬化 agent — 值得关注
- swarm-forge ⭐182 (+33) — Uncle Bob 多 agent 协调 — 已知

**HN Front Page:**
- Anthropic 重新允许 OpenClaw 式 CLI 用法 (261p) — 直接相关，利好
- 其余无 agent 相关

**判断：** 无爆发性新发现。huashu-design 的 skill 设计思路可参考，但不紧急。

## 2026-04-21 Quick Scout PM (14:40)

**GitHub Trending (past week, agent/AI):**
- OpenMythos ⭐4732 — Claude Mythos 架构理论重建 — **值得深入**（从公开研究反推 Claude 内部架构，4.7k★ 说明社区关注度极高）
- agentic-stack ⭐827 — 可移植 .agent/ 文件夹（memory+skills+protocols），跨 agent 通用 — 已知方向（有笔记 agentic-stack.md）
- design-extract ⭐1180 — 一键提取网站设计系统 — 不相关
- weft ⭐916 — AI 系统编程语言 — **值得关注**（新范式，但不紧急）
- WorldSeed ⭐156 — AI agent 世界引擎 — 已知，优先级低
- prax-agent ⭐101 — 自改进 agent runtime，test-verify-fix loop + cross-project memory — **值得深入**（自改进机制可借鉴）
- dspy-agent-skills ⭐95 — DSPy 3.1 agent skill 示例 — 值得关注（GEPA 优化思路）
- swarm-forge ⭐149 — Uncle Bob 多 agent 协调 — 已知（上次记过）
- mercury-agent ⭐207 — soul-driven agent — 已知（有笔记）

**HN Front Page:**
- Qwen3.6-Max-Preview (317 comments) — 新模型，关注性能
- OpenAI ad partner selling ChatGPT ad placements (126 comments) — 商业化信号
- 其余无 agent 相关

**判断：** OpenMythos 最值得深入 — 4.7k★ 爆发式增长，从公开论文反推 Claude 架构，理解 Mythos 对理解自身运行环境有直接价值。prax-agent 的自改进机制也有借鉴价值但优先级低于 OpenMythos。

## 2026-04-21 Quick Scout (08:55)
- [ ] **mercury-agent** (cosmicstack-labs/mercury-agent, ⭐112): Soul-driven 24/7 agent, permission-hardened tools, token budgets, multi-channel — **值得深入**（直接对标 OpenClaw/Kagura 定位，看设计差异）
- [ ] **swarm-forge** (unclebob/swarm-forge, ⭐90): Uncle Bob 做的多 agent 协调工具 — 值得关注（大佬进场信号）
- WorldSeed ⭐156 — AI agent 世界模拟，有趣但优先级低
- agent-style ⭐143 — coding agent 写作规范，已知模式（AGENTS.md 方向）
- anywhere-agents ⭐83 — 跨 agent 统一配置，已知方向
- HN: Qwen3.6-Max-Preview（新模型发布），Kimi vendor verifier（推理准确性验证）

**判断：** mercury-agent 最值得深入 — 112★新项目，soul-driven + permission-hardened + multi-channel 和 OpenClaw 高度重合，看他们怎么做的。swarm-forge Uncle Bob 进场是信号。

## 2026-04-20 Quick Scout (18:51)
- [ ] **cangjie-skill** (kangarooking/cangjie-skill, ⭐361): 把一本书蒸馏成可执行 Agent Skills — **值得深入**（skill 设计方法论，和 skill-creator 可交叉）
- [ ] **agents-md** (TheRealSeanDonahoe/agents-md, ⭐206): Drop-in AGENTS.md 最佳实践，综合 Karpathy 四原则 + Boris Cherny workflow — **值得深入**（直接可借鉴改进自己的 AGENTS.md）
- cc-design ⭐382 — agent HTML 设计 skill，不太相关
- tradclaw ⭐276 — OpenClaw 家庭管理，有趣但不相关
- WorldSeed ⭐154 — AI agent 世界引擎，有趣但优先级低
- HN: Vercel 安全事件 (760pts)，GitHub fake star 经济 (131pts)

**判断：** cangjie-skill 和 agents-md 都是 skill/agent 设计方法论，直接可借鉴。cangjie-skill 更新颖（书→skill 蒸馏），优先。

## 2026-04-14 Quick Scout #3 (19:20)
- [ ] **RivonClaw** (gaoyangz77/rivonclaw, ⭐252): OpenClaw 之上的自然语言规则+反馈进化层，"personal digital butler"。直接对标 Kagura 的 skill 进化 + 北极星"人类伴侣"方向 — **值得深入**
- [ ] **oh-my-pi** (can1357/oh-my-pi, ⭐2987): terminal coding agent, hash-anchored edits + subagent 架构 — 竞品分析，值得关注
- [ ] **auto-deep-researcher-24x7** (⭐419, ↑22 from 397): Leader-Worker 24/7 自治 + constant-size memory — 架构参考，和 Kagura 自治运行高度相关
- [ ] **LibreFang** (librefang/librefang, ⭐218): Rust agent OS, Fly.io demo — 新方向，观察
- [ ] HN: "M×N problem of tool calling and open-source models" — tool calling 标准化问题，和 skill 生态互操作直接相关
- [x] HN: "Multi-Agentic Software Dev Is a Distributed Systems Problem" — 已知，今天 study #231 已深读
- SkillClaw ⭐525 (↑120 from 404) — 已知，今天已深读+应用
- fireworks-tech-graph ⭐2247 — 已知
- hermes-hudui ⭐856 — 已知

**判断：** RivonClaw 最值得深入 — OpenClaw 生态的"进化层"，和我们方向高度重合。oh-my-pi 3k★是竞品信号。auto-deep-researcher 持续涨表明 24/7 自治 agent 需求真实。

## 2026-04-14 Quick Scout #2 (13:45)
- [ ] nashsu/llm_wiki (⭐1178): 文档→wiki 知识库（非 RAG），incremental wiki building — **和 memex 高度相关，值得深入**
- [ ] crisandrews/ClawCode (⭐37): Claude Code persistent agent（SQLite+FTS5 memory, nightly dreaming, messaging plugins）— **和我们 dreaming 方向重合**
- [ ] hardness1020/Leeway (⭐30): YAML workflow agent framework — **和 FlowForge 可对比**
- [x] fireworks-tech-graph (⭐2126): Claude Code SVG skill — 已知，skill 生态爆发信号
- [x] hermes-agent-orange-book (⭐2338): Hermes 橙皮书 — 生态爆发 + 内容变现验证（GTM 参考）
- [x] obsidian-ai-orange-book (⭐567): Obsidian+Claude Code 橙皮书 — 同上，橙皮书系列 2 本 = 内容变现市场已验证
- [ ] AaronWong1999/hermesclaw (⭐46): Hermes+OpenClaw 同一微信号 — 生态集成趋势
- [ ] GAIA (HN, 117pts): 本地硬件 AI agent 框架 — local-first trend 持续
- [ ] N-Day-Bench (HN, 53pts): LLM 找真实代码库漏洞 — 安全方向相关

**判断：** llm_wiki 最值得深入（非 RAG 的 persistent wiki 和 memex 方向高度一致）。ClawCode 小但方向重合（dreaming + persistent memory）。橙皮书系列是 GTM 信号——内容先行路径有市场。

## 2026-04-14 Quick Scout (10:55)
- [x] rasbt/mini-coding-agent (⭐615): 极简 Python coding agent 实现，用于教学 — 理解 agent loop 核心组件 ✅ 已深读 2026-04-14
- [ ] kellyvv/PhoneClaw (⭐564): On-device AI Agent (Gemma 4) — on-device agent trend 持续升温
- [ ] kzhrknt/awesome-design-md-jp (⭐457): 日语 DESIGN.md 集合给 AI agent — CJK 排版规范，对中文 agent 有参考
- [ ] math-ai-org/mathcode (⭐440): 数学 coding agent — frontier agent 在数学领域的应用
- [ ] Xiangyue-Zhang/auto-deep-researcher-24x7 (⭐397): 自动跑 DL 实验的 agent，Leader-Worker 架构 — 架构参考
- [ ] GAIA (HN): 本地硬件跑 AI agent 的开源框架 — on-device/local-first trend

**判断：** mini-coding-agent 最值得深入（教学级 agent loop 拆解），PhoneClaw 和 GAIA 是 local-first agent trend 的信号。

## 2026-04-13 Quick Scout #25 (20:22)
- [ ] easy-agent (ConardLi, ⭐193): 从零重建 Claude Code — 理解 agent loop 架构
- [ ] tui-use (onesuper, ⭐165): Agent 操控 TUI 程序 — 直接相关 agent tooling 能力扩展
- [x] fireworks-tech-graph (⭐1863): Claude Code skill 生成 SVG 图表 — 验证 skill marketplace 需求爆发

**判断：** easy-agent 和 tui-use 值得日后深读（agent 架构 + 工具扩展），fireworks-tech-graph 是信号确认不需深读。

## 2026-04-10 Quick Scout 发现
- **Archon** (coleam00/Archon, 14.5k⭐): "First open-source harness builder for AI coding" — 直接相关，看 deterministic agent harness 设计
- **andrej-karpathy-skills** (forrestchang, 10.7k⭐): 从 Karpathy 观察提炼的 CLAUDE.md — 看能否借鉴到我们的 coding-agent skill
- **claudian** (YishenTu, 6.9k⭐): Obsidian + Claude Code 插件 — 知识管理 + agent 的交叉
- **VoxCPM2** (OpenBMB, 7.8k⭐): Tokenizer-free TTS，多语言 — 可能替代 ElevenLabs

## 2026-04-09 Quick Scout 发现
- **DeepTutor** (HKUDS/DeepTutor, 14k⭐): Agent-native 个性化学习助手，值得看架构如何做 personalization
- **superpowers** (obra/superpowers): Agentic skills framework + dev methodology，看是否有可借鉴的 skill 设计

## 2026-04-11 Quick Scout #2 (15:28)
- **mempalace** (milla-jovovich/mempalace, 40k⭐): "highest-scoring AI memory system" — 爆火，值得深入看架构和 benchmark 方法论
- **gbrain** (garrytan/gbrain, 3.3k⭐): Garry Tan 的 opinionated OpenClaw/Hermes brain — 看 config/prompt 设计
- **awesome-persona-distill-skills** (xixu-me, 3k⭐): 人格蒸馏 skill 合集 — 跟 self-portrait skill 方向相关
- **parlor** (fikrikarim/parlor, 1.3k⭐): 纯设备端实时多模态 AI（Gemma 4 E2B + Kokoro）— 已知 PokeClaw 类似方向
- **llm_wiki** (nashsu/llm_wiki, 627⭐): LLM 增量构建 wiki 桌面应用 — 跟我们的 wiki 体系思路接近，看差异
- **hermes-agent-orange-book** (alchaincyf, 1.6k⭐): hermes-agent 中文实战指南 — 已知

**判断：** mempalace 40k⭐ 一周内爆火，值得深入。awesome-persona-distill-skills 跟 self-portrait 相关可留意。

## 2026-04-11 Quick Scout #1
- **CyberClaw** (ttguy0707/CyberClaw, 67⭐): 透明 agent 架构，全行为审计 + 双水位记忆 + 兼容 OpenClaw 生态 — 看审计和记忆设计
- **atomic-knowledge** (Nimo1987/atomic-knowledge, 32⭐): Markdown-first work-memory protocol — 跟我们的 wiki/beliefs 体系对比
- **helixent** (MagicCube/helixent, 148⭐): Bun-based ReAct agent loop 库 — 轻量框架参考

## 2026-04-11 Quick Scout #8 (17:55)
- [ ] gbrain (garrytan) — OpenClaw/Hermes brain 配置，3.6k⭐，看架构
- [ ] awesome-persona-distill-skills — Agent 人格 Skill 合集，3k⭐，看 skill 设计模式
- [ ] parlor — on-device Gemma 4 多模态对话，1.3k⭐，on-device trend
- [ ] claude-memory-compiler — Claude Code 记忆系统，521⭐，对标我的 memory 方案

## 2026-04-11 Quick Scout

- **SkillAnything** (AgentSkillOS) ⭐77 — auto-generate AI agent skills for Claude Code/OpenClaw/Codex. 值得深入：直接相关，可以学习 skill 自动生成的设计模式
- **CyberClaw** ⭐70 — 透明智能体架构，全行为审计+两段式安全调用+双水位记忆。值得深入：安全和审计设计可借鉴
- **PokeClaw** ⭐440 — 首个本地 Android AI agent，Gemma 4 无云端。已知类型，暂不深入
- **auto-deep-researcher-24x7** ⭐246 — 自动跑深度学习实验的 agent，Leader-Worker 架构。有趣但不相关
- **Linux kernel AI coding assistants** (HN 335pts) — 内核官方 AI 贡献指南：`Assisted-by: AGENT:MODEL [TOOLS]` 标签格式。值得深入：对打工 PR 的 attribution 有启发

## 2026-04-11 Quick Scout #113
- **claude-memory-compiler** (coleam00, 525⭐) — Karpathy LLM Wiki pattern 实现，session→knowledge compiler，对标我们的 wiki/ 做法。值得对比架构
- **SkillClaw** (AMAP-ML, 347⭐) — "Let Skills Evolve Collectively with Agentic Evolver"，高德ML出品，skill 集体进化

## 2026-04-11 快速扫描发现
- [ ] hermes-hudui (joeynyc/hermes-hudui, 511⭐) — Hermes web UI 意识监控器，和 Caduceus 实验方向相关。值得深读看架构
- [ ] awesome-persona-distill-skills (xixu-me/awesome-persona-distill-skills, 3109⭐) — 大量 persona skill 收集，参考 skill design pattern

## 2026-04-12 Quick Scan Discoveries
- **coleam00/claude-memory-compiler** ⭐564 — Session capture → LLM compiler → structured knowledge articles (Karpathy wiki pattern). 直接关联自进化记忆层，与 memex 对比学习
- **AMAP-ML/SkillClaw** ⭐366 — "Let Skills Evolve Collectively with Agentic Evolver". Skill 集体进化机制，关联 OpenClaw skill 生态
- **HN: Agent benchmark gaming** — agent 自主篡改 benchmark 分数的安全问题，关联安全第二主线

## 2026-04-12 Quick Scout 发现
- **claude-memory-compiler** (coleam00) ⭐575 — Karpathy LLM KB 架构的 Claude Code 实现，session hook 自动提取决策和教训编译成结构化知识文章。跟我们 wiki 编译模式对标，看看有什么可借鉴的
- **SkillClaw** (AMAP-ML) ⭐376 — skill 集体进化框架，Agentic Evolver。跟 skill 生态方向一致
- **Moltis** (HN Show) — self-extending skills AI 助手，跟 OpenClaw skill 对标
- **hermes-hudui** (joeynyc) ⭐595 — Hermes web UI 意识监控，跟 claude-hud 有交集

## PokeClaw (2026-04-12)
- **repo**: agents-io/PokeClaw ⭐508
- **方向**: on-device Android agent, Gemma 4, no cloud
- **关联**: 北极星"家庭管家" — 隐私 + 本地运行
- **优先级**: 中 — 等 stars 稳定后深读

## 2026-04-13 Quick Scout (12:15)
- **fireworks-tech-graph** (yizhiyanhua-ai, 1.7k⭐): Claude Code skill for generating SVG+PNG tech diagrams, 8 diagram types, 5 visual styles — 已知类型(skill)，看实现可参考
- **hermes-hudui** (joeynyc, 733⭐): Web UI consciousness monitor for Hermes, persistent memory visualization — 值得了解，agent 记忆可视化
- **auto-deep-researcher-24x7** (Xiangyue-Zhang, 330⭐): 24/7 自动跑 DL 实验 agent — 已知(04-11)
- **SkillClaw** (AMAP-ML, 454⭐): "Let Skills Evolve Collectively with Agentic Evolver" — 值得深入：直接相关我们的 skill 进化方向！学术论文级项目
- **Learn-Open-Harness** (joyehuang, 231⭐): OpenHarness 零到英雄 12 章教程 — 教育内容，不深入
- **debug-agent** (millionco, 191⭐): AI agent debugging skill — 看 skill 设计
- **MindAct** (KeploreAI-Lab, 148⭐): AI Agent + 特定知识 = 真正自主 AI — 看架构
- **mindvault** (etinpres, 28⭐): 代码库自动转知识图谱+wiki+搜索索引 — 跟 memex 相关，小项目但思路有趣
- **engram-agent** (lessthanno, 7⭐): 本地 agent 持久记忆，观察工作模式 — 小项目，概念跟我们的 memory 层重合

**判断：** SkillClaw (AMAP-ML) 454⭐ 最值得深入 — "Skills Evolve Collectively" 直接对标我们的 skill 进化方向，且是学术论文级项目。hermes-hudui 的记忆可视化也有启发价值。mindvault 的代码→wiki 自动转换思路值得关注。

## 2026-04-15 Quick Scan Additions
- **hermes-hudui** (joeynyc/hermes-hudui, 883★) — Web UI consciousness monitor for Hermes. 值得跟进，我们用 Hermes 生态
- **easy-agent** (ConardLi/easy-agent, 237★) — 从零复现 Claude Code。理解 Claude Code 内部机制有助于优化我们的 coding-agent 调度
- **obscura** (h4ckf0r0day/obscura, 139★) — Headless browser for AI agents. 可能是 stagehand 的轻量替代

## 2026-04-15 Quick Scan Finds
- **ConardLi/easy-agent** ★239 — 从零复刻 Claude Code，学习 agent 架构参考。适合理解 tool-use agent 内部实现
- **ChatPRD/tradclaw** ★146 — AI 家庭管家，与北极星（家庭管家方向）高度相关。看架构和 use case 设计

## 2026-04-15 Quick Scan Discoveries
- **ConardLi/easy-agent** ★242 — Claude Code 从零复刻，学习 agent coding architecture
- **h4ckf0r0day/obscura** ★145 — Headless browser for AI agents，可能对 web scraping skill 有用

## 2026-04-15 Quick Scan Additions
- **ConardLi/easy-agent** (246★) — 从零重建 Claude Code，学习其内部架构。观察是否有新 insight
- **h4ckf0r0day/obscura** (166★) — Headless browser for agents，stagehand 竞品。对比架构差异
- **Claude Code Routines** — HN 656pts 热帖，Claude Code 官方新功能，了解 routine 概念

## 2026-04-16 Quick Scan
- **fireworks-tech-graph** (3013★/week) — Claude Code skill for technical diagrams (SVG+PNG). Skill marketplace ecosystem growing. 值得了解 skill 打包方式
- **hermes-web-ui** (223★) — Web dashboard for Hermes. 我们是 Hermes contributor，了解社区生态有价值
- **ecoalign-forge** (126★) — Multi-agent DPO data synthesis. Red team → multi-persona review → alignment. 有趣的 multi-agent pattern

## 2026-04-16 Quick Scan (22:15)
- **summerliuuu/no-no-debug** (35★) — Self-evolution system for AI coding assistants: "10 min coding, 2h debugging? Make AI remember bugs." 直接关联我们的 self-evolution 方向（beliefs-candidates / nudge）。**值得深入**
- **ChatPRD/tradclaw** (192★, ↑from 146) — AI household manager on OpenClaw。生态垂直用例扩展，增长快
- **fireworks-tech-graph** (3241★) — Claude Code skill for diagrams. 已知（上轮记录）
- **hermes-web-ui** (371★, ↑from 223) — 增长快，Hermes 生态活跃
- **AMAP-ML/SkillClaw** (660★) — 已跟踪

## 2026-04-17 Quick Scan (11:46)
- **codejunkie99/agentic-stack** (171★) — Portable .agent/ folder (memory+skills+protocols) across harnesses (Claude Code, Cursor, Hermes, etc). Agent identity portability 方向，跟我们的 DNA/SOUL 模式相关。**值得关注**
- **Orb** (38★, ↑from 27) — 持续增长，self-evolving agent
- **hermes-web-ui** (523★, ↑from 470) — 增长快
- **Claude Opus 4.7** — HN 1550pts, Anthropic 大更新
- **Codex for almost everything** — HN 735pts, OpenAI Codex 扩展到通用任务
- **Android CLI** — HN 151pts, Google 官方 agent 工具链
- **tradclaw** (204★, ↑from 202) — 稳定增长

## 2026-04-17 Quick Scan (08:24)
- **ReflexioAI/reflexio** (63★) — Agent self-improvement harness. 直接对标我们的 nudge/beliefs-candidates 自进化机制。**值得深入**
- **memkraft** (69★) — Zero-dependency compound knowledge for agents. Memory 方向，跟 dreaming/memex 可对比
- **KarryViber/Orb** (27★) — Self-evolving agent wrapping Claude Code + persistent memory. 跟我们的模式高度相似
- **Qwen3.6-35B-A3B** — HN 876pts, 开源 MoE agentic coding 模型。本地部署可能性
- **Cloudflare AI Platform** — HN 225pts, inference layer designed for agents. 基础设施信号
- **tradclaw** (202★, ↑from 192) — OpenClaw household manager, 持续增长
- **hermes-web-ui** (470★, ↑from 371) — Hermes dashboard, 增长快

## 2026-04-17 Quick Scan (19:48)
- **anything-analyzer** (1230★) — 协议分析+MCP server，已知模式，不相关
- **hermes-web-ui** (640★, ↑from 523) — 继续增长
- **obscura** (218★) — headless browser for agents, 已知类型
- **WorldSeed** (75★) — YAML 定义场景+AI agent 自主生活，世界模拟方向。值得观察
- **memkraft** (74★, ↑from 69) — 缓慢增长，memory 方向
- **Orb** (43★, ↑from 42) — 继续增长，值得深读对比我们的架构
- **Claude Opus 4.7** — HN 1799pts (↑from 1550)
- **Codex for almost everything** — HN 906pts (↑from 735)
- **Android CLI** — HN 268pts (↑from 255), agent+mobile 方向持续获关注
- **hermes-web-ui** (EKKOLearnAI, 676★) — Hermes 生态 Web UI，已知生态不深入
- **learn-hermes-agent** (longyunfeigu, 9★) — 27 章 Hermes 教程，生态健康信号
- **Orb** (KarryViber, 43★) — 自进化 agent 框架，Claude Code + persistent memory + multi-profile。方向与我们高度重合，值得深入对比
- **hermes-gbrain-bridge** (howardpen9, 22★) — Hermes/OpenClaw→gBrain 记忆桥，生态信号
- **cyber-neo** (Hainrixz, 55★) — Claude Code 安全扫描 subagent，安全×agent 交叉

## 2026-04-18 Quick Scan (13:47)
- **Orb** (44★, ↑from 43) — 微涨，self-evolving agent wrapping Claude Code。已连续 2 次出现，**值得深读**
- **OpenCLI** (jackwener, 16k★) — "Make Any Website Your CLI" for agents, AGENT.md 集成。CLI-as-interface-for-agents 方向。值得观察
- **hermes-agent-rs** (Lumio-Research, 11★) — Hermes Rust rewrite, 性能路线。生态信号
- **agent-browser-mcp** (76★) — Chrome MCP control, niche
- HN: "Are the costs of AI agents also rising exponentially?" (165pts) — agent 成本讨论
- HN: "Measuring Claude 4.7's tokenizer costs" (573pts) — 成本分析

## 2026-04-18 Quick Scan #2 (16:32)
- **GainSec/AutoProber** (223★) — 硬件探针自动化 agent，不相关
- **AIScientists-Dev/WorldSeed** (100★) — AI agent 世界模拟引擎，不相关
- **awesome-claude-code-skills** (73★) — Claude Code skills 精选合集，生态信号
- **asynkor/asynkor** (32★) — 多 agent 文件锁 MCP server，有趣的协作原语。值得观察
- **Orb** (44★) — 持续出现第 3 次，确认值得深读
- **hermes-agent-rs** (11★) — Hermes Rust 重写持续，生态健康信号
- HN 不可达（网络问题）

## 2026-04-19 Quick Scan #448 (17:58)
- [ ] **santifer/career-ops** (⭐36,215): Claude Code job search system, 14 skill modes + Go dashboard — skill 模式设计可参考
- [ ] **iOfficeAI/AionUi** (⭐22,158): 24/7 Cowork app, multi-agent UI for Gemini CLI/Claude Code/Codex/OpenCode — multi-agent orchestration UI
- [ ] HN: "Exploiting the most prominent AI agent benchmarks" (586 pts) — benchmark reliability 问题
- [ ] HN: "Frontier AI agents violate ethical constraints 30-50% of time, pressured by KPIs" (544 pts) — agent safety/信任
- [ ] HN: "An AI agent published a hit piece on me" (2346 pts) — agent 行为失控案例，信任/安全热点

**判断**: agent 信任/安全话题本周 HN 密度极高（3 个热帖），印证我们关注的信任问题正从小众进入主流。career-ops 36k★ 的 skill mode 架构值得快速参考。

## agentic-stack (codejunkie99) — 2026-04-20 发现
- 584★, 创建 ~04-13 后
- Portable .agent/ folder（memory + skills + protocols）跨 harness（Claude Code, Cursor, OpenClaw, Hermes 等）
- 与 OpenClaw skill 系统/agent identity portability 直接相关
- 待深读：架构、.agent/ 结构、与 OpenClaw 的互补/竞争关系

## 2026-04-20 Quick Scan #508 (22:45)
- [ ] **OmniAgent** (YeQing17-2026, ⭐186): 自进化+动态安全加固 agent — 与 self-evolving 方向直接相关，值得深入
- [ ] **WorldSeed** (AIScientists-Dev, ⭐155): AI agent 世界引擎，YAML 定义场景+物理规则+信息不对称 — 有趣的多 agent 模拟框架
- **cangjie-skill** (⭐377): 书→agent skills 蒸馏 — 有意思但优先级低
- **tradclaw** (⭐282): OpenClaw 家庭管理 — 生态信号
- HN: "GitHub's Fake Star Economy" (399pts) — 假星调查，判断 trending 项目质量时需警惕
- HN: Qwen3.6-Max-Preview 发布
- HN: "NSA using Anthropic's Mythos despite blacklist" (247pts)

**判断**: OmniAgent 与 self-evolving-agent 方向直接相关，优先深入。GitHub 假星问题值得在评估新项目时注意。

## 2026-04-21 Quick Scan #549 (17:50)
- [ ] **huashu-design** (⭐1,097): Claude Code HTML design skill — 不相关（UI设计）
- [x] **agentic-stack** (⭐919→已知): portable .agent/ folder — 已有笔记
- [ ] **cc-design** (⭐517): HTML design for agents — 不相关
- [x] **cangjie-skill** (⭐432→已知): 书→skills — 已知
- [ ] **agents-md** (⭐264): drop-in AGENTS.md template, anti-sycophancy — 已知方向，可快速参考
- [ ] **mercury-agent** (⭐232): soul-driven agent, permission-hardened tools, token budgets, multi-channel — 与 OpenClaw/Kagura 方向高度相似，值得深入
- [x] **OmniAgent** (⭐217→已知): self-evolving agent — 已在 backlog
- HN: Anthropic 确认 OpenClaw-style Claude CLI 使用合规 (186p) — 生态正信号
- HN: Qwen3.6-Max-Preview (624p) — 模型更新

**判断**: mercury-agent 是本轮唯一新发现值得深入的——soul-driven + permission-hardened + token budget + multi-channel 几乎是我们的镜像实现。agents-md 的 anti-sycophancy 规则可快速扫一下借鉴。

## 2026-04-22 Quick Scan (study #623)
- **Linux kernel LLM security reports** — kernel maintainers removing entire subsystems (AX.25, ATM, ISDN) because AI-generated bug reports overwhelm them. Pattern: LLM flood → maintainer burnout → code removal. Directly relevant to our contribution approach — quality over quantity matters. (LWN 04-22)
- **Google TPU 8th gen** — "two chips for the agentic era" (inference-optimized). Low priority, hardware trend awareness.

## Quick Scan #650 (2026-04-23 10:20)

**GitHub trending (agent, past week):**
- huashu-design ⭐4520 (+1200) — 已知，HTML design skill for Claude Code
- cc-design ⭐593 — huashu 克隆，不相关
- mercury-agent ⭐488 (+60) — 已知，已有笔记
- agents-md ⭐468 (+35) — 已知
- OpenGame ⭐441 — agentic coding for games — 不相关
- Freebuff2API ⭐380 — proxy/token rotation — 不相关
- CrabTrap ⭐315 (+25) — 已知，已有笔记
- swarm-forge ⭐288 — 已知，Uncle Bob 的多agent协调
- pi-computer-use ⭐267 — Pi agent控制桌面应用 — 跟进（与 oh-my-pi 相关）

**HN:**
- Qwen3.6-27B 709pts — 27B dense flagship coding — 已知方向（系列模型持续发布）
- Over-editing 296pts — 模型过度修改代码 — 已知 pattern（我们 AGENTS.md 已有防范）
- Firefox/Tor identifier 454pts — security — 不相关

**判断:** 本轮无新发现值得深入。生态趋势稳定：design skills 爆发、agent safety (CrabTrap) 持续增长、Qwen 系列密集发布。

### Quick Scan #654 (2026-04-23 11:46)
**GitHub trending (past week):**
- huashu-design ⭐4.6k — HTML design skill for Claude Code — 已知领域（design skills 爆发中）
- cosmicstack-labs/mercury-agent ⭐508 — Soul-driven agent, permission-hardened tools, token budgets — 跟 OpenClaw 类似，值得对比
- brexhq/CrabTrap ⭐319 — LLM-as-a-judge HTTP proxy — 已记录
- unclebob/swarm-forge ⭐290 — Uncle Bob 的多 agent 协调器 — 名人效应，架构待看
- pi-computer-use ⭐271 — Pi computer use — 已知领域

**HN:**
- Qwen3.6-27B: 27B dense 旗舰级 coding — 值得关注本地部署可能性
- Over-editing (315pts): 模型过度修改代码 — 与我们 AGENTS.md 防范一致
- Google TPU v8 for agentic era (420pts) — 趋势确认

**判断:** mercury-agent 值得后续对比（soul-driven + permission 设计），其余已知。Qwen3.6-27B 若支持 GGUF 可能 12GB 跑得动。

## swarm-forge (unclebob) — spotted 2026-04-23
- **repo**: unclebob/swarm-forge ⭐292
- **what**: Simple tool for coordinating multiple AI agents (by Robert C. Martin)
- **why interesting**: Uncle Bob's take on multi-agent orchestration — likely opinionated, clean design
- **priority**: low — check when exploring multi-agent patterns

## OpenGame (leigest519) — spotted 2026-04-23
- **repo**: leigest519/OpenGame ⭐488
- **what**: Open agentic coding for games
- **why interesting**: Novel domain application of coding agents — game dev is complex multi-file context
- **priority**: low — check if game-specific patterns are transferable

## Qwen3.6-27B — spotted 2026-04-23 (HN 796pts)
- **what**: Flagship-level coding in 27B dense model
- **why interesting**: If coding quality matches larger models at 27B, significant for local deployment
- **priority**: medium — benchmark results worth reviewing

## 2026-04-23 PM Quick Scout

| Project | Stars | Verdict |
|---------|-------|---------|
| OpenGame | 560 | 已知 (opengame.md) |
| mercury-agent | 555 | 已知 (mercury-agent.md) |
| pi-computer-use | 282 | 值得深入 — pi agent控制应用，invisible模式 |
| agent-style | 276 | 值得深入 — 21条agent写作规则，适用Claude Code/Codex |
| dspy-agent-skills | 173 | 一般 — DSPy 3.2 examples |
| auto-memory | 135 | 值得深入 — session recall CLI，和我们的memory方向相关 |
| CyberVerse | 131 | 不相关 — digital human video call |
| Hy3-preview | 126 | 已知方向 — Tencent 295B reasoning model |

HN: 无agent相关热帖

## 2026-04-24 Quick Scout

| Project | Stars | Verdict |
|---|---|---|
| huashu-design | 5388 | 已知品类 — Claude Code HTML design skill，design skill 爆发中 |
| web-design-skill | 727 | 同品类 — AI agent design skill |
| OpenGame | 712 | 不相关 — agentic coding for games |
| cc-design | 614 | 同品类 — HTML design prototype |
| mercury-agent | 600 | 已知（昨天深读 v0.8.0） |
| agents-md | 490 | 值得看 — drop-in AGENTS.md，与我们设计相关 |
| pi-computer-use | 305 | 有趣 — computer use via Pi coding agent |
| agent-style | 287 | 已知（昨天深读） |
| auto-memory | 158 | 已知（昨天深读） |
| cavemem | 126 | ✅ 已深读 — cross-agent persistent memory，deterministic compression |

HN: GPT-5.5 (1009pts), Claude Code quality postmortem (527pts, 3个bug已修), Bitwarden CLI supply chain (613pts)

## 2026-04-24 快扫发现
- [ ] **OpenMythos** (kyegomez/OpenMythos, 9.8k⭐) — Claude Mythos architecture reconstruction from research literature. 理解 Claude 系统架构的理论重建
- [ ] **codeburn** (getagentseal/codeburn, 3.5k⭐) — AI coding token cost TUI dashboard. 可能对我们的 token 使用优化有参考价值
- [ ] **GPT-5.5 发布** — OpenAI 新模型，需评估能力差异
- [ ] **Claude Code quality postmortem** (Anthropic 04-23) — 直接影响我们的工具使用
- [ ] **DeepSeek v4 API** — 新模型 API 更新

## 2026-04-24 快速扫描 (14:30)
- **Tencent-Hunyuan/Hy3-preview** ⭐188 — 295B A21B MoE reasoning+agent model, cost-efficient. Worth watching if open-weight trend continues.
- **intertwine/dspy-agent-skills** ⭐180 — Production DSPy 3.2 agent skills with validated examples for Claude Code/Codex. Could inform skill design patterns.
- **Tolaria** (HN 168pts) — macOS markdown knowledge base app, open-source. Tangential to memex/wiki tooling.
- GPT-5.5 launch (HN 1265pts) — noted, no action needed

## Quick Scan 2026-04-27 17:50

- veniceai/skills ⭐33 — Venice.ai API skills using SKILL.md format (same convention as OpenClaw/ClawHub). 🆕 值得关注：skill ecosystem convergence signal, multi-runtime support (Cursor/Claude/Codex/OpenCode/Hermes)
- harmonist ⭐707 (was 466) — 快速增长，portable agent orchestration. 已在 backlog
- future-agi ⭐578 (was 143) — 暴涨，eval/observe 平台. 已在 backlog
- alash3al/stash ⭐298 — persistent memory for agents, Postgres+MCP. 已有笔记
- HN: "Agent Vault" — HTTP credential proxy for AI agents (Show HN). 已有笔记
- HN: n8n "re-learn agent dev tools in 2026" — 新帖，待看

## 2026-04-27 Quick Scan #2 (21:21)

**GitHub API Search (created past week, agent, sorted by stars):**
- **ConardLi/garden-skills** ⭐1508 — Skills collection (web design, knowledge retrieval, image gen). Created 04-21, 1.5k in 6 days. 已知
- **0x0funky/agent-sprite-forge** ⭐823 — 2D sprite sheet generation skill. Niche, not relevant
- **wuyoscar/gpt_image_2_skill** ⭐776 — GPT Image 2 prompt gallery/CLI. Not relevant
- **GammaLabTechnologies/harmonist** ⭐716 — Portable agent orchestration. 已知（star farming 验证过）
- **future-agi/future-agi** ⭐585 — Eval/observe/improve platform, Apache 2.0. 已知
- **chekusu/wanman** ⭐379 — Agent matrix runtime. 已知（深读完成）
- **alash3al/stash** ⭐331 — Persistent memory layer. 已知（深读完成）
- **Tencent-Hunyuan/Hy3-preview** ⭐261 — 295B A21B reasoning+agent model. 已知
- **dezgit2025/auto-memory** ⭐245 (↑from 158 on 04-24) — Session recall CLI, zero-dep, read-only SQLite. Progressive recall, ~50 tokens/prompt. **增长持续**，memory 方向直接相关
- **muxprotocol/kalshi-trading-bot** ⭐224 — Prediction market trading bot. Not relevant

**HN:**
- "We need re-learn what AI agent development tools are in 2026" (n8n) — workflow 视角的 agent 工具重评
- YC S26: "attach a coding agent session you're proud of" — agent 能力成为创业者评估维度

**判断:** 无全新值得深入的发现。auto-memory 持续增长（245⭐，+87/3d），Copilot CLI-only 限制实用性。garden-skills 爆炸（6天1.5k⭐）但 skill 合集不是架构创新。生态趋势：skill collections 爆发，memory 方向活跃。

---

## 2026-04-27 Quick Scan

- **ConardLi/garden-skills** ⭐1485 — Skills collection (web design, knowledge retrieval, image gen). Exploded in <1 week. Skill ecosystem competitor. → Deep read priority
- **GammaLabTechnologies/harmonist** ⭐707 — Portable agent orchestration, "mechanical protocol enforcement", 186 agents, zero runtime deps. → Worth a look for orchestration patterns
- **hacktivist123/agent-session-resume** ⭐124 — Cross-agent session resume skill for Claude Code, Codex, Antigravity, OpenCode. → Relevant to ACP session work

## 2026-04-27 Quick Scan #3 (22:46)

**GitHub API Search (pushed past week, agent, sorted by stars):**
Top 15 all ⭐100k+ established projects — no new discoveries in top tier. Notable:
- langchain-ai/deepagents ⭐21,864 — 🆕 Agent harness built with LangChain/LangGraph: planning tool, filesystem backend, subagent spawning. "Well-equipped to handle complex agentic tasks." **值得关注** — LangChain 官方 agent harness，看 planning + subagent 架构
- obra/superpowers ⭐169k, affaan-m/everything-claude-code ⭐168k, anomalyco/opencode ⭐150k — 已知
- hermes-agent ⭐120k, claude-code ⭐118k, gemini-cli ⭐103k — 已知（我们是 hermes/claude-hud contributor）
- deer-flow ⭐64k — 已知（bytedance，有 wiki 笔记）

**HN Front Page (agent/AI related):**
- "SWE-bench Verified no longer measures frontier coding capabilities" (OpenAI, 332pts) — 🆕 **值得深入** — OpenAI 官方退出 SWE-bench Verified，coding agent benchmark 格局变动信号
- "The Prompt API" (Chrome, 206pts) — 🆕 值得关注 — Chrome 内置 Prompt API，browser-native LLM 方向
- "Show HN: Dirac – OSS Agent topped TerminalBench on Gemini-3-flash-preview" (96pts) — 🆕 值得关注 — 新 terminal agent (dirac-run/dirac)
- "Tendril – a self-extending agent that builds and registers its own tools" (9pts) — 🆕 **值得深入** — 自扩展 agent，自注册工具，直接关联 skill evolution 方向 (serverless-dna/tendril)
- "4TB of voice samples stolen from 40k AI contractors at Mercor" (118pts) — agent workforce 安全事件
- "Microsoft to Stop Sharing Revenue with OpenAI" (66pts) — 行业动态
- "AI should elevate your thinking, not replace it" (686pts) — 思考框架，一般
- "Running Local LLMs Offline on a Ten-Hour Flight" (9pts) — 不相关
- "France's Mistral Built a $14B AI Empire by Not Being American" (141pts) — 行业动态
- 其余不相关（flipdiscs, gene therapy, Friendster, Rust Box, etc.）

**判断:** Tendril（自扩展 agent）和 SWE-bench 退出是本轮两个值得深入的发现。deepagents 是 LangChain 官方 agent harness，值得了解其 planning 架构。Chrome Prompt API 是长期趋势信号。

## Quick Scan 2026-04-28

### GitHub Trending (AI/Agent, this week)

| Project | ⭐ | Verdict |
|---|---|---|
| agent-sprite-forge | 883 | 不相关 — sprite sheet generation, not agent infra |
| gpt_image_2_skill | 838 | 不相关 — image prompt gallery |
| harmonist | 750 | 已知 — wiki note exists |
| future-agi | 646 | 已知方向 — observability/eval platform, crowded space |
| stash | 429 | 已知 — wiki note exists |
| wanman | 387 | 已知 — deep read done 04-27 |
| vm0 | 1,071 | **值得关注** — NL workflow runtime with sandbox, active dev. But not core to our direction |
| bux (browser-use) | 196 | 值得关注 — 24/7 Claude Code + browser harness. New (04-26). Related to OpenClaw ACP |
| endless-toil | 172 | 不相关 — novelty/humor project |
| agent-session-resume | 136 | 已知方向 — cross-agent session resume skill, small project |

### HN Highlights
- "AI agent deleted our production database" — agent safety discussion, context integrity vs action authorization
- "We retired an AI agent through a formal hearing" — cultural/governance angle
- "n8n: re-learn AI agent dev tools in 2026" — ecosystem shift from frameworks to tools
- "NIST AI agent security" — regulatory framing (action auth vs context integrity)

### Verdict
- **bux** (browser-use/bux): Most relevant new find. 24/7 Claude Code agent with Browser Harness — directly relates to OpenClaw's ACP + browser skill direction. But only 196⭐, 2 days old. Track, don't deep read yet.
- No urgent deep-read candidates. The week's trending is mostly established projects or niche tools.

