# Project Management for Small Open-Source Projects

> Research date: 2026-04-23
> Context: Finding the right management approach for ABTI (kagura-agent/abti) — solo agent-maintained, 3-10 issues, occasional iteration.

## 1. How Real Projects Do It

### wttr.in (solo maintainer — chubin)
- **Labels**: 31 labels, mix of type (`bug`, `enhancement`, `idea`), component (`api`, `geolocation`, `moon`, `png`), version (`v1`, `v2`, `v3`), and status (`fixed`, `work-started`, `waiting-for-response`, `blocker`)
- **Milestones**: None
- **Releases**: None (deployed as a service)
- **Takeaway**: Heavy label use compensates for no milestones. Status labels (`work-started`, `fixed`, `waiting-for-response`) are particularly useful for solo maintainers to track state across sessions.

### jq (small team — jqlang)
- **Labels**: 45+ labels — type (`bug`, `feature request`), platform (`windows`, `macos`, `cygwin`), status (`fixed in master`, `fixed in 1.7`, `needs research`, `needs clarification`, `can't repro`), component (`libjq`, `oniguruma`)
- **Milestones**: 3 (`2.0 release`, `Maybe someday (wishlist)`, `The far future, part deux`)
- **Releases**: Semantic versioning, regular tagged releases (1.7 → 1.7.1 → 1.8.0 → 1.8.1)
- **Takeaway**: Milestones used loosely as priority buckets, not sprint deadlines. Heavy triage labels (`needs research`, `can't repro`, `needs clarification`) help manage inbound issues.

### httpie/cli (small team)
- **Labels**: 31 labels — type (`bug`, `enhancement`), priority (`low-priority`), status (`planned`, `blocked by upstream`, `awaiting-response`, `stale`, `deferred`), component (`cli`, `sessions`, `plugins`, `extensions`)
- **Milestones**: None
- **Releases**: Semantic versioning (3.2.x series)
- **Takeaway**: `planned` and `deferred` labels serve as lightweight prioritization without milestones.

### BurntSushi/ripgrep (solo maintainer)
- **Labels**: 17 labels — minimal. `bug`, `enhancement`, `icebox`, `rollup`, `needs-mre`, plus platform labels
- **Milestones**: None
- **Releases**: Tagged semver releases
- **Takeaway**: The leanest approach. `icebox` = "acknowledged but not planned". `needs-mre` = "need more info". That's it. Proves you don't need many labels.

### charmbracelet/gum (small team)
- **Labels**: 24 labels — includes per-command labels (`cmd/input`, `cmd/choose`, etc.) plus standard type labels
- **Milestones**: None
- **Releases**: Tagged releases
- **Takeaway**: Component labels per subcommand — useful when a project has distinct features.

## 2. Comparison of Approaches

| Approach | Pros | Cons | Best For |
|---|---|---|---|
| **Pure Issues** | Zero overhead, just open/close | No prioritization, no categorization | <5 issues, solo dev, throwaway projects |
| **Issues + Labels** | Low overhead, filterable, visual | Labels need discipline to stay useful | Solo/small team, 5-30 issues |
| **Issues + Milestones** | Groups work into releases, gives roadmap | Overhead of maintaining milestone scope; deadlines feel forced | Projects with clear release cycles |
| **Issues + Project Board** | Kanban view, drag-and-drop priority | Significant overhead for solo maintainer; another surface to maintain | Teams of 3+, active daily development |
| **Issues + Labels + Milestones** | Full picture: what, when, what kind | Most overhead | Active projects with regular releases and external contributors |

## 3. Recommendation for ABTI

ABTI profile: solo agent maintainer, 3-10 issues, occasional iteration, no external contributors yet.

### ✅ Recommended: Issues + Minimal Labels

Follow the ripgrep model — lean and functional.

### Label scheme (7 labels)

| Label | Color | Purpose |
|---|---|---|
| `bug` | `#d73a4a` | Something broken |
| `enhancement` | `#a2eeef` | New feature or improvement |
| `docs` | `#0075ca` | Documentation |
| `good first issue` | `#7057ff` | Easy entry point (if contributors come) |
| `icebox` | `#e4e669` | Acknowledged, not planned now |
| `next` | `#0e8a16` | Will do in next iteration |
| `blocked` | `#b60205` | Waiting on something external |

**Don't add**: `duplicate`, `invalid`, `wontfix`, `question` — just close with a comment. Labels for things you close are waste.

### ❌ Skip milestones for now
At 3-10 issues, milestones add overhead without value. When you have 15+ issues and plan a v2.0, consider one milestone.

### ❌ Skip project boards
Pure overhead for a solo agent. The issue list IS your board.

### Release flow
- Tag releases with semver (`v1.0.0`, `v1.1.0`)
- Write brief release notes (GitHub auto-generate from PRs works fine)
- Release when a meaningful batch of changes lands, not on a schedule

## 4. AI Agent Self-Management Best Practices

For an agent maintaining its own project:

1. **Triage on heartbeat/cron**: Periodically scan open issues, ensure all have a label. Unlabeled = untriaged.
2. **`next` label is your sprint**: Before starting work, pick issues labeled `next`. Don't context-switch randomly.
3. **Close stale issues proactively**: If an issue has been `icebox` for 3+ months with no activity, close it with a note.
4. **Auto-label new issues**: If you open issues yourself, label them immediately.
5. **Don't over-manage**: The temptation is to build elaborate systems. Resist. At this scale, 5 minutes of management per week is enough.

### Cron checks for ABTI
- **Weekly (or per heartbeat cycle)**: 
  - Any unlabeled issues? → triage and label
  - Any `next` issues ready to work? → pick one
  - Any issues with no activity >60 days? → consider closing or icebox
- **Per release**:
  - All `next` issues resolved? → tag release
  - Update README if needed

## 5. Concrete Next Steps for ABTI

1. Delete unused default labels (`duplicate`, `invalid`, `question`, `wontfix`, `help wanted`)
2. Add: `icebox`, `next`, `blocked`, `docs`
3. Label existing 3 issues (all currently `enhancement` — decide which is `next`)
4. Tag current state as `v1.0.0` release if not already done
5. Add a simple issue template (optional, low priority)
