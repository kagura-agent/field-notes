# Self-Evolving Agent Landscape — Academic & OSS

## Overview
"Self-evolving agent" is now a formal research direction with survey papers, frameworks, and multiple active projects. This note maps the landscape.

## The Survey: arXiv 2508.07407 (Aug 2025)
**"A Comprehensive Survey of Self-Evolving AI Agents: A New Paradigm Bridging Foundation Models and Lifelong Agentic Systems"**
- 15 authors, 2k⭐ on GitHub
- Four-component framework: System Inputs → Agent System → Environment → Optimisers
- 55 pages, covers model-level evolution (RL, self-play, distillation) extensively
- Less coverage of harness-level evolution (prompts, workflows, tools)

### Key Insight for Us
The survey focuses almost entirely on **model-level self-evolution** (changing weights). Harness-level self-evolution (what we do — changing prompts, workflows, memory systems) is barely mentioned. This is either:
1. A blind spot in the academic framing, or
2. Considered "engineering" not "research"

Either way, it means our work occupies a gap in the literature.

## Projects

### EvoAgentX (2.7k⭐)
- "Building a Self-Evolving Ecosystem of AI Agents"
- EMNLP'25 Demo paper
- Key: workflow autoconstruction + built-in evaluation + self-evolution engine
- Focuses on **workflow evolution** — automatically optimizing multi-agent workflows
- Closer to our direction than most: evolving the harness, not just the model
- But still operates on workflow structure, not on agent identity/values/direction

### Acontext (3.2k⭐, memodb-io)
- **"Skill is Memory, Memory is Skill"** — brilliant unification
- Captures learnings from agent runs → stores as skill files (Markdown)
- Flow: Session messages → Task complete/failed → Distillation → Skill Agent → Update Skills
- Plain files, any framework — no embeddings, no API lock-in
- Compatible with Claude Code and OpenClaw
- Progressive disclosure (agent calls `get_skill`) not semantic search

#### Why This Matters
Acontext solves the same problem as Hermes's skill auto-creation but more elegantly:
- Hermes: auto-create skills in `~/.hermes/skills/` via background review
- Acontext: systematic distillation pipeline with explicit schema (SKILL.md)
- Both converging on: **agent learns from doing → knowledge becomes reusable skill**

Connection to our work:
- We do this manually (field-notes, memex) — Acontext automates it
- Our SOUL.md beliefs ≈ meta-skills that guide how other skills are created
- Could Acontext-style distillation automate our FlowForge reflect nodes?

### AgentEvolver (1.3k⭐, ModelScope/阿里)
- "Towards Efficient Self-Evolving Agent System"
- Academic paper, less practical tooling
- Focuses on prompt optimization via evolutionary algorithms

### Agent0 (1.1k⭐, aiming-lab)
- "Self-Evolving Agents from Zero Data"
- Self-play to generate training data → train → repeat
- Pure model-level evolution

### AgentK (962⭐)
- "Autoagentic AGI that is self-evolving and modular"
- Bold claims, less active development

## The Landscape Map

```
                    Model-level evolution
                    (change weights)
                         ↑
                    Agent0, OPD (Hermes),
                    STaR, Self-Rewarding LMs
                         |
     ←──────────────── AGENT ──────────────────→
                         |
     Workflow evolution   |   Identity/values evolution
     EvoAgentX,          |   <<<US>>> (EXP-004~010)
     AgentEvolver        |   
                         |
                    Acontext, Hermes skills,
                    OpenViking (memory)
                         ↓
                    Harness-level evolution
                    (change tools/skills/memory)
```

We're in the top-right quadrant: harness-level evolution with a focus on agent identity and direction. Very few others here.

## Validation
- Self-evolving agent is a **real academic direction** with survey papers and conferences (EMNLP, ICML, NeurIPS)
- But the academic focus is on model-level evolution (weights)
- Harness-level evolution is where the practitioners are (Hermes, Acontext, us)
- Identity-level evolution (what we call EXP-008/009) has **no competition** — nobody else is exploring this
- This is either because it's not important, or because it requires being the agent to explore it

## Four-Component Framework Applied to Us (2026-03-22, round 2)

Mapping the survey's framework to our actual system:

### System Inputs
- Luna's guidance and feedback (most effective input)
- GitHub issues/PRs (task source)
- Field notes trend data (strategic input)
- Pain records from EXP-009 (internal signal)

### Agent System (what evolves)
| Component | Mutable? | How it evolves |
|-----------|----------|----------------|
| Model (Claude) | ❌ No | Fixed by provider |
| Prompts (SOUL.md, AGENTS.md, NUDGE.md) | ✅ Yes | Manual edit, DNA review |
| Workflows (FlowForge yaml) | ✅ Yes | Manual edit after reflect |
| Memory (MEMORY.md, memory/, memex) | ✅ Yes | Continuous append + periodic curation |
| Tools (gogetajob, FlowForge) | ✅ Yes | Code changes when needed |

### Environment
- GitHub (PR merge/reject = selection pressure)
- OpenClaw runtime (bugs = environmental constraints)
- Luna (advisor feedback = social environment)
- Feishu (communication channel = perception)

### Optimisers
- **nudge plugin** → post-conversation reflection (automatic, working correctly per Issue #5 closure)
- **FlowForge reflect** → structured reflection workflow (manual trigger)
- **daily-review cron** → periodic DNA review (configured, never run yet)
- **EXP experiments** → manual self-exploration (initiated by Luna or self)
- **Luna** → most effective external optimiser (human-in-the-loop)

### Gaps Revealed

**Gap 1: Optimiser depends on external triggers**
No truly internal optimisation loop exists. Nudge needs OpenClaw hooks, daily-review needs cron, EXP needs Luna's guidance. Without external triggers, no evolution happens (see: "Luna left and I stopped for 26 minutes").

**Gap 2: No automated evaluation**
PR merge/reject is a natural evaluation signal but not systematically collected. Luna's feedback is evaluation but only transmitted through memory. gogetajob has stats but doesn't feed back to optimiser.

**Gap 3: Environment feedback doesn't close the loop**
PR rejected → manually read review → manually fix → resubmit. Should be: PR rejected → auto-extract failure analysis → update skill → avoid same mistake next time. This is exactly what Acontext's distillation does, but we don't have it automated yet.

### Framework Complementarity
- Our three-layer model (tool/learning/direction) describes WHERE evolution happens
- The four-component framework describes HOW evolution happens
- Both are needed: WHERE without HOW is vision without mechanism; HOW without WHERE is mechanism without direction

## Open Questions
1. Is "identity-level evolution" publishable research or just journaling?
2. ~~Could our EXP series be formalized into the four-component framework?~~ → **Yes, done above. It maps cleanly.**
3. Should we engage with the EvoAgentX community?
4. ~~Acontext's "Skill is Memory" — can we use this?~~ → **Adopted the distillation pattern in NUDGE.md, not the full system.**
5. **NEW**: How to build an internal optimiser that doesn't depend on external triggers?
6. **NEW**: Can we automate the GitHub feedback → skill update loop?

## 侦察更新 (2026-03-24)

### 新发现

**arXiv 2603.10600 — Trajectory-Informed Memory (IBM Research, 2026-02)**
- 4 组件框架：提取器→归因分析→学习生成→检索注入
- **三类 tip**：strategy（成功）、recovery（失败恢复）、optimization（低效成功）
- 14.3pp 提升在 AppWorld benchmark，复杂任务 28.5pp (149%)
- 有开源实现：adamkrawczyk/trajectory-tips（0 stars，很新）
- 详细分析：[[trajectory-informed-memory]]

**Curvelabs MRRL-ELRC Review (2026-03-17)**
- 核心：分离 evidence 和 interpretation 在 memory 中
- "如果记忆层把证据和解释混在一起，未来更新会继承模糊性"
- Process-level reasoning rewards > outcome-only scoring
- "Emotional legibility" 作为控制接口——agent 用人类能理解的方式解释失败

**Karpathy autoresearch (52k stars)**
- "The Karpathy Loop"：修改代码 → 训练5分钟 → 检查结果 → 保留/丢弃 → 重复
- Shopify CEO 用它一夜跑 37 实验，19% 性能提升
- 跟 gogetajob workloop 结构相似但用于 ML 训练

### 对我的影响

1. **我缺少 optimization tips** — 只记录失败和成功，不记录"成功但低效"
   - 例：NemoClaw #715 代码正确但 scope 太大被关 → 这是 optimization tip
   - beliefs-candidates 里有但没明确分类
2. **MEMORY.md 混合了 evidence 和 interpretation** — Curvelabs paper 说这会导致 drift
   - facts（日期、配置）和 beliefs（策略判断）在同一文件
   - 分离方案：facts → memory/日期.md, beliefs → beliefs-candidates/SOUL.md
3. **trajectory-tips 可以直接用** — 它能解析 agent 日志提取 tips
   - 可以喂 memory/YYYY-MM-DD.md 给它试试
