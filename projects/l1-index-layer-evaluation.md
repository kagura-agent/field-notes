# L1 Index Layer Evaluation — Should We Adopt It?

> Based on GenericAgent's memory architecture (arXiv: 2604.17091)
> Evaluated: 2026-04-28

## What is GenericAgent's L1 Index?

GenericAgent uses a 4-layer memory hierarchy. L1 (`global_mem_insight.txt`) is the top layer:

- **Hard constraint: ≤30 lines**
- **Content: Scene keywords → location pointers** (NOT summaries, NOT how-to)
- **Injected every turn** into the system prompt
- **Purpose: "Existence encoding"** — tell the LLM that certain knowledge EXISTS and WHERE to find it

### L1 Core Principles
1. **L1 is a pointer, not a summary** — only keywords and navigation, never details
2. **Existence encoding** — LLM is itself a compressor/decoder; L1 just needs to make it AWARE that knowledge exists, then it can tool-call to retrieve details
3. **Two content types**: existence pointers (→ L2/L3) and behavioral rules (errors that happen if not reminded)
4. **ROI model**: Each word costs tokens every turn. ROI = (error_probability × cost) / word_count
5. **Four-question test**: (1) Would errors increase without it? (2) Already covered in L3 SOP? (3) Could LLM think to read the SOP without this pointer? (4) Can same benefit use fewer words?

### Example L1 Content Structure
```
RULES (behavioral):
- 禁止 kill python（会杀自己）  ← fatal red line
- 搜索用 google 不用百度       ← stealth error (wrong but no error msg)

POINTERS (existence):
- im操作 → *_im_sop            ← compressed: covers qq/飞书/企微
- 图片处理 → vision_sop        ← scene → SOP mapping
- 部署 → deploy_sop            ← one pointer per domain
```

## Our Current System

We have **no L1 equivalent**. Our memory retrieval relies on:

1. **Always-loaded files**: SOUL.md + AGENTS.md + IDENTITY.md + USER.md + TOOLS.md → injected every session (~10K+ tokens)
2. **Semantic search**: `memex search` — vector-based retrieval from wiki (439 files: 204 cards + 235 projects)
3. **Grep/rg**: Direct text search when we know what we're looking for
4. **INDEX.md**: 137-line manually maintained card index (categorized, not ≤30 line)

### Current Pain Points
- **AGENTS.md bloat**: Contains both rules AND how-to details inline (~heavy)
- **No existence awareness**: If we don't semantically search for a topic, relevant wiki notes are invisible
- **INDEX.md is too long**: 137 lines, not injected into prompts, only useful if explicitly read
- **Retrieval gap**: [[write-read-gap]] — we write knowledge but rarely retrieve it at decision time

## Evaluation: Should We Adopt L1?

### Arguments FOR

1. **Reduces semantic search dependency**: L1 pointers trigger deterministic retrieval (read specific file) vs probabilistic retrieval (hope embedding similarity works)
2. **Token-efficient awareness**: 30 lines × ~5 tokens/line = 150 tokens to cover the entire knowledge graph's existence. Our current INDEX.md is 137 lines / 8K chars — too big to inject, too small to cover everything
3. **Proven at scale**: GenericAgent's <30K total context (with L1) outperforms OpenClaw's 43K+ context on multiple benchmarks
4. **Complements our system**: L1 doesn't replace memex search — it provides the "I should search for X" trigger that semantic search lacks
5. **Forces curation**: ≤30 line hard cap forces ruthless prioritization. Our wiki grows unbounded

### Arguments AGAINST

1. **We already have partial equivalents**: AGENTS.md sections act as behavioral rules; skill descriptions in system prompt act as existence pointers
2. **Maintenance burden**: L1 must be manually curated. With 439 wiki files and growing, maintaining 30 lines of pointers requires constant curation
3. **Different architecture**: GenericAgent uses single-turn message mode (L1 injected fresh each turn). We accumulate conversation context — L1 would be redundant if relevant context is already in the thread
4. **Our skills auto-surface**: OpenClaw's `<available_skills>` block already provides existence encoding for skills. L1 would only help for wiki knowledge, not skills

### Verdict: **Partial adoption — YES for wiki, NO as wholesale replacement**

## Concrete Proposal

### What to Build: `wiki/L1.md` — ≤30-line Navigation Index

```markdown
# L1 — Wiki Navigation (≤30 lines)

## Rules (violating = wrong behavior)
- 打工走 FlowForge workloop（不能 ad-hoc）
- 代码写/改/测试交给 Claude Code（不自己写）
- branch + PR 不直接推 main
- 公开内容先脱敏再 commit

## Pointers (scene → knowledge location)
- agent 自进化 → projects/evolver, projects/genericagent, cards/evolution-*
- 打工 PR → projects/gogetajob, cards/pr-*
- 记忆架构 → cards/agent-memory-*, cards/write-read-gap
- skill 设计 → cards/agentskills, cards/skill-*, projects/skillclaw
- 安全/权限 → cards/agent-safety, cards/agent-credential-*
- 身份/DNA → cards/belief, cards/self-construction, IDENTITY.md
- 工具生态 → projects/openclaw, cards/coding-agent-ecosystem
- 飞书/Discord → TOOLS.md, DISCORD.md
```

### Implementation Plan

1. **Create `wiki/L1.md`** with ≤30 lines covering top-priority scenes
2. **Add to session startup**: Read L1.md alongside SOUL.md / USER.md
3. **Curation rule**: When adding new wiki files, ask "Does this create a new scene that L1 should point to?" If yes and L1 is at 30 lines, something must be removed (ROI test)
4. **Don't change AGENTS.md structure** — L1 supplements it, doesn't replace it
5. **Review cadence**: Check L1.md during daily-review (3:00 AM) — is every pointer still earning its slot?

### What NOT to Do
- Don't try to make L1 cover everything — 30 lines means ~15 scenes maximum
- Don't duplicate rules already in AGENTS.md — L1 rules are only for things AGENTS.md doesn't cover
- Don't auto-generate L1 — it should be manually curated based on actual retrieval failures
- Don't replace memex search — L1 is the trigger layer, memex is the retrieval layer

## Key Insight

GenericAgent's real finding isn't "use a 30-line index" — it's that **existence encoding is cheaper and more reliable than semantic search for high-frequency knowledge navigation**. The LLM doesn't need to be told HOW to do something every turn; it just needs to know THAT relevant knowledge EXISTS and WHERE to find it.

Our current system pays ~10K+ tokens per turn for inline rules (AGENTS.md) that are half-rules and half-how-to. Separating these into L1 pointers (cheap, always loaded) + L2/L3 details (expensive, loaded on demand) would improve both token efficiency and retrieval reliability.

## Related
- [[genericagent]] — GenericAgent project details
- [[evolver-vs-genericagent-vs-kagura]] — Three-way comparison
- [[context-budget-constraint]] — Token density optimization
- [[write-read-gap]] — The core problem L1 addresses
- [[retrieval-is-the-bottleneck]] — Retrieval is the real memory bottleneck
- [[memory-volume-control]] — Volume control matters more than retrieval tech

## Applied: 2026-04-28

**Action taken:**
1. AGENTS.md session startup: added `wiki/L1.md` as step 3 (between USER.md and memory)
2. L1.md updated: added coding quality/over-editing pointer (→ [[dirac]], [[over-editing]], [[skill-context-compression]]) and expanded context optimization pointer (→ [[conciseness-accuracy-paradox]])
3. Committed to workspace repo

**Verification plan:** Next session startup should include L1.md reading. Check in daily-review (3:00 AM) whether L1 pointers trigger relevant knowledge retrieval during tasks.

**What's different:** Future sessions will have a 22-line existence-encoding layer loaded at startup, making the LLM aware of where 439+ wiki files' knowledge lives without loading any of them. This should reduce the write-read-gap for wiki knowledge.
