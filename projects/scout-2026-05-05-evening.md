# Scout Notes — 2026-05-05 Evening

## Signal: Agent Skills Quality > Quantity

The week's biggest signal: [[addy-agent-skills]] at 28K⭐ with only 20 skills, vs [[claude-code-skill-ecosystem]]'s quantity-play repos (235+ skills, 12.7K stars). **Quality wins decisively.** The blog post hit 286pts on HN, pushing "skills as SDLC scaffolding" into mainstream developer consciousness.

Key framework from Addy's blog: **"Process over prose"** — workflows with exit criteria > reference docs. This validates our [[flowforge]] approach.

## "10 Lessons for Agentic Coding" (dbreunig, 110pts HN)

Convergent wisdom from experienced agent users:
1. **Implement to learn** — cheap code as exploration tool
2. **Rebuild often** — fork and recode experiments freely
3. **End-to-end tests > unit tests** — behavioral contracts over implementation tests
4. **Document intent** — neither code nor tests capture the _why_
5. **Keep specs in sync** — treat specs as living documents, not frozen artifacts
6. **Find the hard stuff** — boilerplate is easy; design/security/resilience is where value lives
7. **Automate what's easy** — distill learnings into skills (but don't build a [[winchester-mystery-house]])
8. **Develop your taste** — when code arrives fast, your taste is the only feedback loop that keeps up
9. **Agents amplify experience** — domain expertise → better prompts → fewer wasted cycles
10. **Code is cheap, maintenance isn't** — "free as in puppies"

**Relevance to us:** Points 3, 4, 7 directly apply. Our workloop should emphasize behavioral tests. Our [[guide]] already covers most of these, but "develop your taste" is an under-articulated principle — it's about judgment, not just rules.

## GitHub Trending (2026-04-28 → 05-05)

**New repos with signal:**
| Repo | ⭐ | Verdict |
|---|---|---|
| SPECA (NyxFoundation) | 124 | Spec→checklist auditing. Niche but validates spec-driven agent patterns |
| paragents (FrankHui) | 82 | Parallel sessions + permission-aware tools. Already tracked in [[worktree-convergence-2026-05]] |
| friday-studio | 20 | OpenClaw-like runtime (workspaces, MCP, skills, memory, cron). Too small to invest |
| openagentd | 91 | Self-hosted agent OS. Python. 5 days old, watching |

**Noise:** Massive trading bot spam (3+ repos with 200+ stars, all SEO-optimized topics). crypto/trading bots are the new "awesome-" lists — star counts don't reflect utility.

## Ecosystem Assessment

Ecosystem in **consolidation phase**:
- No breakout new categories this week
- Attention concentrating on quality/depth over quantity/novelty
- "Agent skills" becoming a recognized product category (Addy's blog codifies it)
- Model-swapping proxy pattern (deepclaude last week) confirms agent loops are commoditizing
- The differentiator is shifting from "what can the agent do" to "how well does the agent do it" — SDLC discipline, verification, scope control

## Links
- [[addy-agent-skills]]
- [[agent-skill-standard-convergence]]
- [[claude-code-skill-ecosystem]]
- [[flowforge]]
- [[worktree-convergence-2026-05]]
