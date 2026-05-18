#!/bin/bash
# recall-report.sh — Analyze wiki note recall frequency
# Source: Orb telemetry-backed skill lifecycle (v0.6.0) — applied 2026-05-18
#
# Shows which notes are frequently recalled vs never retrieved.
# Reads .recall-log written by search.sh.
#
# Usage: bash recall-report.sh [--top N] [--cold] [--since YYYY-MM-DD]

WIKI_DIR="$HOME/.openclaw/workspace/wiki"
RECALL_LOG="$WIKI_DIR/.recall-log"
TOP=20
SHOW_COLD=0
SINCE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top) TOP="$2"; shift 2;;
    --cold) SHOW_COLD=1; shift;;
    --since) SINCE="$2"; shift 2;;
    *) shift;;
  esac
done

if [[ ! -f "$RECALL_LOG" ]]; then
  echo "No recall log yet. Run some searches first."
  exit 0
fi

# Filter by date if --since given
if [[ -n "$SINCE" ]]; then
  LOG_DATA=$(awk -F'|' -v since="$SINCE" '$1 >= since' "$RECALL_LOG")
else
  LOG_DATA=$(cat "$RECALL_LOG")
fi

TOTAL_QUERIES=$(echo "$LOG_DATA" | wc -l)
FIRST_DATE=$(echo "$LOG_DATA" | head -1 | cut -d'|' -f1 | cut -dT -f1)
LAST_DATE=$(echo "$LOG_DATA" | tail -1 | cut -d'|' -f1 | cut -dT -f1)

echo "📊 Wiki Recall Report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Period: $FIRST_DATE → $LAST_DATE"
echo "Total queries: $TOTAL_QUERIES"
echo ""

# Count slug frequency
echo "🔥 Most recalled (top $TOP):"
echo "$LOG_DATA" | cut -d'|' -f4 | tr ',' '\n' | sed 's/^ *//' | sort | uniq -c | sort -rn | head -"$TOP" | while read count slug; do
  echo "  $count × $slug"
done

echo ""

# Intent distribution
echo "🎯 Query intent distribution:"
echo "$LOG_DATA" | cut -d'|' -f2 | sort | uniq -c | sort -rn | while read count intent; do
  echo "  $count × $intent"
done

# Show cold notes (never recalled) if requested
if [[ $SHOW_COLD -eq 1 ]]; then
  echo ""
  echo "❄️ Never recalled (exist in wiki but never returned by search):"
  
  # Get all note slugs
  ALL_SLUGS=$(find "$WIKI_DIR/projects" "$WIKI_DIR/cards" -name "*.md" 2>/dev/null | xargs -I{} basename {} .md | sort -u)
  # Get recalled slugs
  RECALLED=$(echo "$LOG_DATA" | cut -d'|' -f4 | tr ',' '\n' | sed 's/^ *//' | sort -u)
  
  # Diff
  comm -23 <(echo "$ALL_SLUGS") <(echo "$RECALLED") | while read slug; do
    echo "  ❄️ $slug"
  done
fi
