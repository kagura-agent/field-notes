#!/bin/bash
# retire-candidates.sh — Auto-retire scoring for wiki notes
# Source: Elephant Agent auto-retire pattern (stale claims automatically retired)
# Applied: 2026-05-19
#
# Scores wiki notes by staleness, combining:
#   1. Age (days since last modified) — older = higher score
#   2. Recall frequency (from .recall-log) — never recalled = higher score
#   3. Frontmatter status (dropped/stale > scout > active)
#   4. Orphan status (no inbound links = higher score)
#
# Score range: 0-100. Higher = more likely candidate for retirement.
# Threshold: score >= 60 → suggest review, >= 80 → strong retire candidate
#
# Usage: bash retire-candidates.sh [--threshold N] [--top N] [--json]

WIKI_DIR="$HOME/.openclaw/workspace/wiki"
RECALL_LOG="$WIKI_DIR/.recall-log"
THRESHOLD=60
TOP=20
JSON=0
NOW=$(date +%s)

while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2;;
    --top) TOP="$2"; shift 2;;
    --json) JSON=1; shift;;
    *) shift;;
  esac
done

# Build recall frequency map from log
declare -A RECALL_COUNT
if [[ -f "$RECALL_LOG" ]]; then
  while IFS= read -r slug; do
    slug=$(echo "$slug" | xargs)  # trim
    [[ -z "$slug" ]] && continue
    RECALL_COUNT["$slug"]=$(( ${RECALL_COUNT["$slug"]:-0} + 1 ))
  done < <(cut -d'|' -f4 "$RECALL_LOG" | tr ',' '\n' | sed 's/^ *//')
fi

# Build orphan set (notes with no inbound links)
declare -A HAS_INBOUND
while IFS= read -r target; do
  # Skip targets with special chars that break associative arrays
  [[ "$target" =~ ^[a-zA-Z0-9_-]+$ ]] || continue
  HAS_INBOUND["$target"]=1
done < <(grep -roh '\[\[[^]]*\]\]' "$WIKI_DIR/projects/" "$WIKI_DIR/cards/" 2>/dev/null | sed 's/\[\[//;s/\]\]//' | sort -u)

# Recall log maturity: if < 7 days of data, reduce recall weight
LOG_DAYS=0
if [[ -f "$RECALL_LOG" ]]; then
  FIRST_LOG_DATE=$(head -1 "$RECALL_LOG" | cut -d'|' -f1 | cut -dT -f1)
  LAST_LOG_DATE=$(tail -1 "$RECALL_LOG" | cut -d'|' -f1 | cut -dT -f1)
  FIRST_EPOCH=$(date -d "$FIRST_LOG_DATE" +%s 2>/dev/null || echo "$NOW")
  LOG_DAYS=$(( (NOW - FIRST_EPOCH) / 86400 + 1 ))
fi
# Recall data too young (<7 days) → halve recall score weight
RECALL_IMMATURE=0
if [[ $LOG_DAYS -lt 7 ]]; then
  RECALL_IMMATURE=1
fi

# Score each note
declare -a RESULTS=()

score_note() {
  local filepath="$1"
  local slug=$(basename "$filepath" .md)
  local dir=$(dirname "$filepath")
  local category=$(basename "$dir")  # projects or cards
  
  # 1. Age score (0-30): days since mtime, capped at 30 days = max score
  local mtime=$(stat -c %Y "$filepath" 2>/dev/null || echo "$NOW")
  local age_days=$(( (NOW - mtime) / 86400 ))
  local age_score=$(( age_days > 30 ? 30 : age_days ))
  
  # 2. Recall score (0-30): never recalled = 30, recalled 1-2x = 15, 3+ = 0
  local recall_key="$slug"
  # Also check with projects/ prefix
  local recall=${RECALL_COUNT["$recall_key"]:-0}
  local prefixed_recall=${RECALL_COUNT["$category/$recall_key"]:-0}
  local total_recall=$(( recall + prefixed_recall ))
  local recall_score
  if [[ $total_recall -eq 0 ]]; then
    recall_score=30
  elif [[ $total_recall -le 2 ]]; then
    recall_score=15
  else
    recall_score=0
  fi
  # Halve recall weight if log is immature (< 7 days)
  if [[ $RECALL_IMMATURE -eq 1 ]]; then
    recall_score=$(( recall_score / 2 ))
  fi
  
  # 3. Status score (0-25): from frontmatter
  local status=$(head -20 "$filepath" | grep -m1 "^status:" | sed 's/status: *//' | tr -d '"' | tr -d "'")
  local status_score=10  # default (no status)
  case "$status" in
    dropped|stale|archived|dead) status_score=25;;
    scout|stub) status_score=15;;
    active|tracking) status_score=5;;
    deep-dive|reference) status_score=0;;
  esac
  
  # 4. Orphan score (0-15): no inbound links = 15
  local orphan_score=0
  if [[ -z "${HAS_INBOUND[$slug]}" ]]; then
    orphan_score=15
  fi
  
  local total=$(( age_score + recall_score + status_score + orphan_score ))
  
  # Only include if above threshold
  if [[ $total -ge $THRESHOLD ]]; then
    RESULTS+=("$total|$slug|age=${age_days}d|recalls=$total_recall|status=${status:-none}|orphan=$([ $orphan_score -gt 0 ] && echo 'yes' || echo 'no')")
  fi
}

# Scan all wiki notes
for f in "$WIKI_DIR"/projects/*.md "$WIKI_DIR"/cards/*.md; do
  [[ -f "$f" ]] || continue
  # Skip index files
  [[ "$(basename "$f")" == "INDEX.md" ]] && continue
  [[ "$(basename "$f")" == "backlog.md" ]] && continue
  score_note "$f"
done

# Sort by score descending, take top N
SORTED=$(printf '%s\n' "${RESULTS[@]}" | sort -t'|' -k1 -rn | head -"$TOP")

if [[ $JSON -eq 1 ]]; then
  echo "["
  first=1
  while IFS='|' read -r score slug age recalls status orphan; do
    [[ -z "$score" ]] && continue
    [[ $first -eq 0 ]] && echo ","
    echo "  {\"score\":$score,\"slug\":\"$slug\",\"$age\",\"$recalls\",\"$status\",\"$orphan\"}"
    first=0
  done <<< "$SORTED"
  echo "]"
else
  echo "🗑️ Wiki Retire Candidates (threshold ≥ $THRESHOLD)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Stats
  total_notes=$(find "$WIKI_DIR/projects" "$WIKI_DIR/cards" -name "*.md" ! -name "INDEX.md" ! -name "backlog.md" 2>/dev/null | wc -l)
  candidate_count=${#RESULTS[@]}
  local recall_entries=$(wc -l < "$RECALL_LOG" 2>/dev/null || echo 0)
  echo "Total notes: $total_notes | Candidates: $candidate_count | Recall log: ${recall_entries} entries, ${LOG_DAYS}d"
  if [[ $RECALL_IMMATURE -eq 1 ]]; then
    echo "⚠️  Recall log immature (<7 days). Recall scores halved. Results improve with more search data."
  fi
  echo ""
  
  if [[ -z "$SORTED" ]]; then
    echo "  No candidates above threshold $THRESHOLD."
  else
    echo "Score | Slug                              | Details"
    echo "------|-----------------------------------|--------"
    while IFS='|' read -r score slug details; do
      [[ -z "$score" ]] && continue
      # Reconstruct details from remaining fields
      remaining=$(echo "$details" | sed 's/|/ /g')
      printf " %3d  | %-35s | %s\n" "$score" "$slug" "$remaining"
    done <<< "$SORTED"
  fi
  
  echo ""
  echo "Legend: score = age(0-30) + recall(0-30) + status(0-25) + orphan(0-15)"
  echo "  ≥80: strong retire candidate | ≥60: review needed"
  echo ""
  echo "Actions: archive (move to wiki/archive/), compress (reduce to stub), or delete"
fi
