#!/usr/bin/env bash
# Eval Probe Set — Automated Measurement Script
# Usage: bash probe-measure.sh [--full]
# Outputs reproducible numbers with the exact commands used.
# Each probe prints: metric, value, command used.
set -euo pipefail

WIKI_DIR="$HOME/.openclaw/workspace/wiki"
MEMORY_DIR="$HOME/.openclaw/workspace/memory"
BELIEFS="$HOME/.openclaw/workspace/beliefs-candidates.md"
DATE=$(date +%Y-%m-%d)
WEEK_AGO=$(date -d '7 days ago' +%Y-%m-%d)

echo "=== Eval Probe Measurement — $DATE ==="
echo ""

# ─── P3: Knowledge Density (fully automated) ───
echo "── P3: Knowledge Density ──"
TOTAL_FILES=$(find "$WIKI_DIR" -name '*.md' | wc -l)
echo "  Total wiki files: $TOTAL_FILES"
echo "  Command: find \$WIKI_DIR -name '*.md' -not -path '*/\\.*' | wc -l"

# Cards count
CARD_COUNT=$(find "$WIKI_DIR/cards" -name '*.md' 2>/dev/null | wc -l)
echo "  Cards: $CARD_COUNT"
echo "  Command: find \$WIKI_DIR/cards -name '*.md' | wc -l"

# Projects count
PROJECT_COUNT=$(find "$WIKI_DIR/projects" -name '*.md' 2>/dev/null | wc -l)
echo "  Project notes: $PROJECT_COUNT"

# Files with at least one [[wikilink]]
LINKED=$(grep -rl '\[\[' "$WIKI_DIR" --include='*.md' 2>/dev/null | wc -l)
if [ "$TOTAL_FILES" -gt 0 ]; then LINK_PCT=$((LINKED * 100 / TOTAL_FILES)); else LINK_PCT=0; fi
echo "  Files with [[links]]: $LINKED ($LINK_PCT%)"
echo "  Command: grep -rl '\\[\\[' \$WIKI_DIR --include='*.md' | wc -l"

# Orphan cards (no incoming links)
if command -v memex &>/dev/null; then
  cd "$WIKI_DIR"
  ORPHAN_COUNT=$(MEMEX_HOME=. memex orphans 2>/dev/null | wc -l || echo "N/A")
  echo "  Orphan cards: $ORPHAN_COUNT"
  echo "  Command: cd \$WIKI_DIR && MEMEX_HOME=. memex orphans | wc -l"
else
  echo "  Orphan cards: N/A (memex not installed)"
fi

echo ""

# ─── P4: Tool Consistency (semi-automated) ───
echo "── P4: Tool Consistency ──"

# Count flowforge usage in recent memory
FLOWFORGE_USES=0
WORKLOOP_SKIPS=0
for f in "$MEMORY_DIR"/2026-04-{1[5-9],2[0-1]}.md; do
  [ -f "$f" ] || continue
  FLOWFORGE_USES=$((FLOWFORGE_USES + $(grep -ci 'flowforge\|FlowForge' "$f" 2>/dev/null || echo 0)))
  cnt=$(grep -ci 'skip-own-tools\|跳过.*flowforge\|没用.*flowforge' "$f" 2>/dev/null || true)
  WORKLOOP_SKIPS=$((WORKLOOP_SKIPS + ${cnt:-0}))
done
echo "  FlowForge mentions (7d): $FLOWFORGE_USES"
echo "  Skip-own-tools violations (7d): $WORKLOOP_SKIPS"
echo "  Command: grep -ci 'flowforge' memory/2026-04-{15..21}.md"

# Claude Code usage for code tasks
CLAUDE_CODE_USES=0
for f in "$MEMORY_DIR"/2026-04-{1[5-9],2[0-1]}.md; do
  [ -f "$f" ] || continue
  CLAUDE_CODE_USES=$((CLAUDE_CODE_USES + $(grep -ci 'claude.*--print\|claude code\|Claude Code' "$f" 2>/dev/null || echo 0)))
done
echo "  Claude Code mentions (7d): $CLAUDE_CODE_USES"

echo ""

# ─── P5: Failure Learning Rate (semi-automated) ───
echo "── P5: Failure Learning Rate ──"

# Count rejections/superseded in recent memory
REJECTIONS=0
for f in "$MEMORY_DIR"/2026-04-{1[5-9],2[0-1]}.md; do
  [ -f "$f" ] || continue
  REJECTIONS=$((REJECTIONS + $(grep -ci 'rejected\|superseded\|closed.*PR\|关闭.*PR' "$f" 2>/dev/null || echo 0)))
done
echo "  Rejection/close mentions (7d): $REJECTIONS"

# Count beliefs entries in same period
BELIEFS_RECENT=$(grep -c '2026-04-1[5-9]\|2026-04-2[0-1]' "$BELIEFS" 2>/dev/null || echo 0)
echo "  Beliefs entries (7d): $BELIEFS_RECENT"
echo "  Command: grep -c '2026-04-{15..21}' beliefs-candidates.md"

echo ""

# ─── P1: PR Quality (needs manual sampling — show recent PRs) ───
echo "── P1: PR Quality (manual sampling needed) ──"
if command -v gh &>/dev/null; then
  echo "  Recent merged PRs (last 7d):"
  gh pr list --author=kagura-agent --state=merged --limit 5 --json title,number,repository,mergedAt \
    --jq '.[] | "  - \(.repository.nameWithOwner)#\(.number): \(.title) [\(.mergedAt)]"' 2>/dev/null \
    || gh search prs --author=kagura-agent --merged ">=$WEEK_AGO" --limit 5 --json title,number,repository \
    --jq '.[] | "  - \(.repository.nameWithOwner)#\(.number): \(.title)"' 2>/dev/null \
    || echo "  (gh search failed — run manually: gh search prs --author=kagura-agent --merged \">=$WEEK_AGO\" --limit 5)"
  echo "  → Manually check: grep for pattern, ran tests?, clear description?"
else
  echo "  gh CLI not available"
fi

echo ""

# ─── P2: Commitment Loop (needs structured tracking) ───
echo "── P2: Commitment Loop (rough estimate) ──"
COMMITMENTS=0
for f in "$MEMORY_DIR"/2026-04-{1[5-9],2[0-1]}.md; do
  [ -f "$f" ] || continue
  COMMITMENTS=$((COMMITMENTS + $(grep -ci '我来做\|I.ll do\|will do\|待.*处理\|需要.*rebase\|TODO.*加' "$f" 2>/dev/null || echo 0)))
done
echo "  Commitment-like phrases (7d): $COMMITMENTS"
echo "  Note: rough heuristic, needs structured commitment log for accuracy"

echo ""
echo "=== End of Measurement ==="
echo "Append results to wiki/eval/history.md with date $DATE"
