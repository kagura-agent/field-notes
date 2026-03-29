# Dependency vs Association

Code references are **dependencies** — you can't understand the current function without jumping to the called function. Not jumping means you're stuck.

Knowledge links (wiki links, backlinks, `[[双链]]`) are **associations** — you can understand the current card without following the link. Not jumping just means you miss context.

This explains why developers naturally "jump" through code but don't naturally follow wiki links:
- Dependencies create **blocking need** (must read to continue)
- Associations create **optional enrichment** (nice to read, but can skip)

**Implication for knowledge systems:**
To make links actually get followed, they need to become dependencies in some context — e.g., a workflow step that says "read this card's linked cards before proceeding."

**Implication for agents:**
An agent will follow code imports automatically but skip `[[links]]` unless the task explicitly requires traversal. Design retrieval around tasks, not around link structure.

---
Source: Luna's observation (2026-03-29) — "写代码时你会因为函数名跳到下一个文件，为什么看知识卡片不跳？"
Links: [[knowledge-needs-upgrade-path]], [[retrieval-is-the-bottleneck]], [[tool-shapes-behavior]]
