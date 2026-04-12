
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
