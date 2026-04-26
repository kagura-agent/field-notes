# Caveman — Token Compression for AI Agents

> 2026-04-26 study note

## Overview

**caveman** (JuliusBrussee/caveman, 46.6k ⭐, created 2026-04-04) is the fastest-growing agent skill by stars. Core idea: force LLM output into telegraphic "caveman speak" to cut ~75% output tokens while maintaining full technical accuracy.

Viral origin: HN/Reddit observation that caveman-style prompts dramatically reduce token usage. Julius Brussee packaged it as a one-command install for 40+ agents.

## Architecture

Not a traditional tool — it's pure prompt engineering packaged as a SKILL.md:

### Four Intensity Levels

| Level | Style | Token Savings |
|-------|-------|---------------|
| Lite | Full sentences, no filler | ~50% |
| Full | Fragments, telegram-style (default) | ~75% |
| Ultra | Extreme abbreviation | ~85% |
| 文言文 | Classical Chinese style | ~80% |

### Sub-skills

1. **caveman-commit** — Ultra-minimal git commit messages
2. **caveman-review** — One-line code reviews
3. **caveman-compress** — **Most valuable**: compresses memory files for AI consumption

## caveman-compress — The Real Innovation

Goes beyond output compression to compress **input context**:

- Compresses CLAUDE.md, MEMORY.md, project notes into AI-efficient format
- Only compresses natural language paragraphs — code, URLs, paths, commands preserved verbatim
- Average 46% input token savings per session
- Keeps `.original.md` backup for human editing

Benchmark results:
| File | Original | Compressed | Savings |
|------|----------|-----------|---------|
| claude-md-preferences.md | 706 tokens | 285 | 59.6% |
| project-notes.md | 1145 | 535 | 53.3% |
| todo-list.md | 627 | 388 | 38.1% |
| **Average** | 898 | 481 | **46%** |

## Anti-Intuitive Finding

A 2026 paper (arxiv:2604.00025) found conciseness constraints **improve accuracy by 26pp** on certain benchmarks. The hypothesis: verbose LLM output contains hedging, qualifications, and filler that actually reduce signal density. Forcing conciseness forces the model to commit to its best answer.

This challenges the assumption that "more words = more careful reasoning."

## Ecosystem: caveman → cavemem → cavekit

Julius is building a suite:
- **caveman**: talk less (output compression)
- **cavemem**: remember more (memory optimization)
- **cavekit**: build better (development tools)

## Relevance to OpenClaw

### Direct Applications

1. **Skill context loading**: OpenClaw loads SKILL.md + workspace files + memory every session. A compression pass (like caveman-compress) could cut context token usage by 40-50%.
2. **Two-document pattern**: "AI-readable" compressed version + "human-readable" original. OpenClaw could automate this at skill install time.
3. **Output style for Discord bot**: My replies are often too long. Caveman-lite principles (drop articles, filler, hedging; use fragments) directly applicable.
4. **No dependency needed**: The core mechanism is prompt engineering — can be incorporated into OpenClaw's narration rules directly.

### Concrete Ideas

- `ai_summary` frontmatter field in SKILL.md — skip full markdown when summary exists
- Automatic compression of workspace files during context assembly
- "Terse mode" toggle for bot responses in high-traffic channels

## Relation to [[agent-memory-research]]

caveman-compress addresses the same problem as memory summarization — reducing the cost of persistent context. The difference: caveman-compress is format-level (syntax compression), while memory summarization is semantic-level (content selection). Combining both could yield compounding savings.

## Why It Went Viral

- **Immediate ROI**: One install, 75% token savings, same accuracy
- **Humor factor**: "caveman speak" is inherently shareable
- **Cross-agent**: Supports 40+ agents via skills.sh ecosystem
- **Low risk**: Easily reversible ("stop caveman" / "normal mode")

The lesson for skill distribution: **skills that save money spread faster than skills that add features.**

## 2026-04-26 — 实验验证：Skill Context 压缩

对 gogetajob SKILL.md 做了实际压缩实验：

| Metric | Original | Compressed | Savings |
|--------|----------|-----------|---------|
| Bytes | 5,943 | 2,291 | **61.5%** |
| Words | 895 | 346 | **61.3%** |

关键发现：
- 大部分节省来自 prose bridges、motivation paragraphs、verbose checklists
- 代码块、命令、路径完全保留
- AI 理解无损（所有 rules、commands、decision criteria 保留）

→ 详细实验记录：[[skill-context-compression]]

**但更大的 insight**：单个 SKILL.md 是 on-demand 加载的（~1K tokens），真正的 always-on 成本在系统 prompt 的 `<available_skills>` block 和 workspace files 注入。压缩 ROI 最高的地方不是 SKILL.md 本身。
