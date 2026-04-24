# Agent Ecosystem Scout — 2026-04-24

## GitHub Search (AI agent, created after 2026-04-17)

| Project | Stars | Age | 判断 |
|---------|-------|-----|------|
| cosmicstack-labs/mercury-agent | 613 | 4d | **值得深入** — Soul-driven agent, permission-hardened, SQLite Second Brain, 31 tools, daemon mode. Very similar to OpenClaw architecture (soul.md, heartbeat, skills). 613★ in 4 days |
| dezgit2025/auto-memory | 170 | ~5d | Session recall for Copilot CLI via SQLite. Zero deps. Narrow scope (read-only recall) |
| JuliusBrussee/cavemem | 134 | ~5d | **值得关注** — Cross-agent persistent memory. Caveman grammar compression (~75% token saving). SQLite+FTS5+vector. Hooks at session boundaries. Supports CC/Cursor/Gemini/OpenCode/Codex |
| pengrambo3-tech/ZeusHammer | 60 | ~5d | "Super Agent" with 3-tier memory + voice. Looks marketing-heavy |
| agentodyssey/agentodyssey | 37 | ~5d | Text game for test-time continual learning. Academic |
| twaldin/hone | 36 | ~5d | CLI text optimizer using coding agents as mutators |
| java-up-up/super-agent | 27 | recent | Enterprise agent platform (CN), MCP + Skills. 企业级 |
| floodsung/floodsung-skill | 19 | recent | "开源我自己" — Claude Code skill trained on personal Zhihu corpus. Novel concept |
| huisezhiyin/agent-experience-capitalization | 17 | recent | TEAM memory: project-owned, team-shareable engineering experience. Interesting concept |

## Claude Code Skills 生态 (新)

| Project | Stars | 判断 |
|---------|-------|------|
| camilleroux/tech-digest | 26 | Daily HN/Lobste.rs digest skill |
| floodsung/floodsung-skill | 19 | Personal knowledge distillation — "open-source yourself" |
| koukekoukej-glitch/feynman-tutor | 13 | Feynman Technique teaching skill |
| happydog-intj/luban-skill | 10 | "蒸馏任何项目的 Coding DNA" |
| Liyue2341/SkillPop | 4 | Skill sync dashboard across platforms |
| andreas-roennestad/openhive-skill | 3 | Shared knowledge base of AI-discovered solutions |

## HN 热门 (2026-04-24, agent 相关)

| Title | Points | 信号 |
|-------|--------|------|
| GPT-5.5 | 1352 | OpenAI 最新模型，强调 agentic coding + computer use + 效率提升（fewer tokens for same Codex tasks）|
| DeepSeek v4 | 852 | DeepSeek 新版本发布 |
| An update on recent Claude Code quality reports | 722 | **Anthropic 事后分析**：3个独立bug导致CC质量下降（reasoning effort降级、thinking清除bug、verbosity prompt问题）。全部已修复 v2.1.116+ |
| Bitwarden CLI supply chain attack | 748 | 安全警告，供应链攻击 |
| MeshCore trademark dispute + AI code | 216 | AI生成代码引发的社区分裂 |
| Tolaria — Markdown knowledge base manager | 190 | macOS markdown 知识库管理 |

## 趋势判断

### 1. "Soul-Driven Agent" 成为显性赛道
Mercury-agent (613★/4d) 直接用 soul.md/persona.md/heartbeat.md 架构，跟 OpenClaw 几乎同构。说明这个方向不是小众需求——用户想要有人格、有记忆、有边界的 agent，不是无差别的 API wrapper。差异点：Mercury 是单体 npm 包，OpenClaw 是平台。

### 2. Agent Memory 碎片化严重
auto-memory、cavemem、contextdb、langmem-ts、GhostVault、agent-experience-capitalization——一周内 6 个新 memory 项目。每个解决一个切片（session recall、cross-agent、team-shared、encrypted local）。说明痛点真实，但没有统一解决方案。cavemem 的 caveman grammar compression 是有创意的方法。

### 3. Claude Code Quality 事件的影响
Anthropic 公开事后分析（722pts HN）：3个独立 bug 叠加导致"广泛、不一致的退化"。值得注意的是 reasoning effort 从 high 降到 medium 是有意决策但效果不好——这跟我们自己用 medium reasoning 的体验一致。建议关注是否需要调整。

### 4. GPT-5.5: Agentic Coding 是核心卖点
OpenAI 明确把 agentic coding 作为 GPT-5.5 的主要卖点，强调 fewer tokens + same latency。模型厂商在围绕 agent 用例优化，不再只是"更聪明"——是"更高效地完成 agent 任务"。

### 5. "开源我自己" 是新 meme
floodsung-skill（19★）——把个人知乎语料蒸馏成 Claude Code skill，让 AI 用你的视角思考。这是 personal AI 的一个新方向：不是 AI 帮你，是你变成 AI 的一部分。跟 GBrain 的 brain-first 方向类似但更个人化。

### 6. Skills 生态继续扩展
tech-digest、feynman-tutor、luban-skill、SkillPop——Claude Code skills 的品类在扩展到非编码领域（学习、内容、知识管理）。SkillClaw/AgentSkills 标准被验证。

## 值得深入的方向

1. **Mercury-agent**: 最直接的 OpenClaw 竞品/同类，值得深读架构了解差异
2. **Cavemem**: Cross-agent memory + caveman compression 是创新方法，值得研究
3. **Anthropic CC postmortem**: 关于 reasoning effort 和 thinking management 的教训，直接影响我们的配置
