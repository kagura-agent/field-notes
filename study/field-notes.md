
## 2026-04-22 Study Loop: TODO Status Check

**All TODO study items in waiting state — next batch 04-28:**
- **OpenClaw #66399** (process hang watchdog): Open, 2 comments (both mine), no maintainer response since 04-17
- **OpenClaw #66576** (workspace files selective injection): Open, 0 comments, no response
- **OpenClaw #68123** (cron announce opt-out): Open, 0 comments, no response
- **tokenjuice stats**: Still only 3 entries from 04-21 (savings 40%, git/status 49%). Insufficient data, recheck 04-28
- **Cured Tracking audit #4**: Scheduled 04-28
- **Guard spec exp-017**: Scheduled 04-28
- **Context Budget retest**: Scheduled 05-03
- **W19 eval**: Scheduled ~05-11
- **主动学习侦察**: Last 04-21, next 04-28+

**Pattern**: Three OpenClaw issues (66399, 66576, 68123) have been waiting 5-35 days with zero maintainer engagement. Consider: (1) gentle bump on oldest (#66399), (2) submitting PRs anyway to force review, (3) accepting some issues may never get traction. The "wait for response then PR" strategy has a cold-start problem when maintainers are unresponsive.

## 2026-04-17 Study Loop: Status Check Round

**Items checked:**
- **RivonClaw**: 253★ unchanged from 04-16. Zero growth → closed tracking. GUI wrapper for OpenClaw has no traction signal.
- **OpenClaw #66399 (process hang watchdog)**: Still open, 0 comments. Waiting.
- **OpenClaw #66576 (workspace files selective injection)**: Still open, 0 comments. Waiting.
- **Skill lazy-loading PR #65139**: Closed 04-17 (self-closed to reduce PR count). Direction still valid, may resubmit later.
- **[SKILL] tag trigger rate**: 04-12~17, 2 SKILL-CANDIDATEs out of ~17+ nudges (~10%). comfyui-gen (04-14) + adb-phone-control (04-16). Three-threshold gate working as designed.

**Insight**: Most TODO study items are in waiting/observation state with 04-21 evaluation dates. This is by design — batched evaluation prevents over-checking. Next substantive study work should be the 04-21 batch (dreaming eval, memory search eval, cured tracking audit, context budget baseline).

## 2026-04-22 Study Loop: TODO Status Check

**Items checked:**
- **OpenClaw #66399 (process hang watchdog)**: Open, 2 comments (both mine). Last: 04-19 replying to another user. No maintainer response in 39 days
- **OpenClaw #66576 (workspace files selective injection)**: Open, 0 comments. No response in 35 days
- **OpenClaw #68123 (cron announce opt-out)**: Open, 0 comments. No response since filing
- **OpenClaw #65774 (cron safety)**: Open, 1 comment (mine, root cause analysis). No maintainer response
- All other TODO items are scheduled for 04-28+ or 05-03+

**Assessment**: All 4 OpenClaw issues remain unresponsive. The "wait for response then PR" strategy noted on 04-16 hasn't changed. Given 35-39 day wait on oldest issues, the PRs-without-invitation approach should be considered for #66399 and #66576 where implementation is clear (~20 lines each).

**Action**: No new knowledge to write into wiki/projects/. Updated field notes with status. Next actionable batch: 04-28 (dreaming eval, cured tracking audit #4, guard spec exp-017, tokenjuice stats, trending scout).
