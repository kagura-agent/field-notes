#!/bin/bash
# search.sh — Hybrid wiki search (semantic + keyword)
# Mitigates known RAG failure modes (F1 negation, F2 numeric, F3 role-swap)
# by combining memex cosine similarity with grep keyword matching.
#
# Source: krusch-context-mcp → Sentra RAG failure mode taxonomy study (2026-05-10)
#
# Usage: bash search.sh "<query>" [--limit N] [--keyword-only] [--semantic-only]
#
# Output: deduplicated list of matching files with match source indicator

set -uo pipefail

WIKI_DIR="$HOME/.openclaw/workspace/wiki"
LIMIT=5
MODE="hybrid"
QUERY=""
DEBUG=0

# Intent-aware recall reranking
# Source: elephant-agent intent-aware recall (plan_recall_query), applied 2026-05-18
# Classifies query intent to adjust temporal decay:
#   recent  → δ=0.35 (strong recency bias, penalize old)
#   current → δ=0.50 (very strong freshness, only recent relevant)
#   historical → δ=0.05 (preserve old context, minimal decay)
#   neutral → δ=0.17 (default Darr et al.)
classify_intent() {
  local q="$1"
  # Recent intent: user wants recent/new information
  if echo "$q" | grep -qiE '最近|lately|recently|last.week|last.month|new|新的|recent|刚|刚才|latest|这几天|近期'; then
    echo "recent"
  # Current intent: user wants current state
  elif echo "$q" | grep -qiE '现在|now|current|today|今天|目前|ongoing|正在|当前|此刻'; then
    echo "current"
  # Historical intent: user wants past context
  elif echo "$q" | grep -qiE '当初|之前|originally|早期|history|历史|used.to|back.when|以前|过去|曾经|起初|最初|一开始'; then
    echo "historical"
  else
    echo "neutral"
  fi
}

get_decay_rate() {
  case "$1" in
    recent)     echo "0.35" ;;
    current)    echo "0.50" ;;
    historical) echo "0.05" ;;
    *)          echo "0.17" ;;
  esac
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit) LIMIT="$2"; shift 2 ;;
    --keyword-only) MODE="keyword"; shift ;;
    --semantic-only) MODE="semantic"; shift ;;
    --debug) DEBUG=1; shift ;;
    *) QUERY="$1"; shift ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Usage: bash search.sh \"<query>\" [--limit N] [--keyword-only] [--semantic-only]"
  exit 1
fi

# Classify query intent
INTENT=$(classify_intent "$QUERY")
DECAY_RATE=$(get_decay_rate "$INTENT")
[[ "$INTENT" != "neutral" ]] && echo "🎯 Intent: $INTENT (decay δ=$DECAY_RATE)"
[[ $DEBUG -eq 1 ]] && echo "[DBG] intent=$INTENT decay_rate=$DECAY_RATE" >&2

declare -A SEEN
RESULTS=()

# ---- Semantic search (memex) ----
if [[ "$MODE" == "hybrid" || "$MODE" == "semantic" ]]; then
  echo "🔮 Semantic results (memex):"
  MEMEX_OUT=$(cd "$WIKI_DIR" && MEMEX_HOME=. memex search --all "$QUERY" --limit "$LIMIT" 2>/dev/null || true)
  if [[ -n "$MEMEX_OUT" ]]; then
    echo "$MEMEX_OUT"
    # Extract slugs from memex output (## slug-name lines)
    while IFS= read -r line; do
      slug=$(echo "$line" | grep '^## ' | sed 's/^## //')
      if [[ -n "$slug" ]]; then
        SEEN["$slug"]=1
        RESULTS+=("  🔮 $slug")
      fi
    done <<< "$MEMEX_OUT"
  else
    echo "  (no results)"
  fi
  echo ""
fi

# ---- Keyword search (grep) ----
if [[ "$MODE" == "hybrid" || "$MODE" == "keyword" ]]; then
  echo "🔍 Keyword results (grep):"
  
  # Split query into individual terms, search for each
  # For multi-word queries, also search exact phrase
  KEYWORD_FILES=""
  
  # Exact phrase search
  EXACT=$(grep -rl "$QUERY" "$WIKI_DIR/projects/" "$WIKI_DIR/cards/" 2>/dev/null | head -"$LIMIT" || true)
  
  # Individual significant words (skip common words)
  WORDS=$(echo "$QUERY" | tr ' ' '\n' | grep -v -iE '^(the|a|an|is|are|was|were|with|for|and|or|not|about|more|than|that|this|from|have|has|been|will|can|could|would|should|of|in|on|at|to|by|how|do|does|did|its|into|also|just|like|very|much|being|each|when|what|who|where|which|why|get|got|make|made|some|any|all|own|use|used|using)$' || true)
  
  WORD_FILES=""
  WORD_ARRAY=()
  for word in $WORDS; do
    if [[ ${#word} -ge 3 ]]; then
      WORD_ARRAY+=("$word")
    fi
  done
  NUM_WORDS=${#WORD_ARRAY[@]}
  # For short queries (1-2 words), require ALL words. For longer, require 60%
  if [[ $NUM_WORDS -le 2 ]]; then
    MIN_MATCH=$NUM_WORDS
  else
    MIN_MATCH=$(( (NUM_WORDS * 3 + 4) / 5 ))  # ceil(60%)
  fi
  # Score each file by how many query terms it contains
  declare -A FILE_SCORES
  for word in "${WORD_ARRAY[@]}"; do
    found=$(grep -rli "$word" "$WIKI_DIR/projects/" "$WIKI_DIR/cards/" 2>/dev/null || true)
    while IFS= read -r f; do
      [[ -n "$f" ]] && FILE_SCORES["$f"]=$(( ${FILE_SCORES["$f"]:-0} + 1 ))
    done <<< "$found"
  done
  # Filter files meeting minimum match threshold
  for f in "${!FILE_SCORES[@]}"; do
    if [[ ${FILE_SCORES["$f"]} -ge $MIN_MATCH ]]; then
      WORD_FILES="${WORD_FILES}${WORD_FILES:+$'\n'}$f"
    fi
  done
  
  # Merge exact + intersection results, deduplicate, rank by decay-weighted maturity score
  # Insight: AgentOps decay-ranked retrieval (δ=0.17/week) + maturity weights
  # Source: agentops.md (Darr et al. knowledge decay), applied 2026-05-13
  NOW=$(date +%s)
  ALL_KEYWORD=$(echo -e "${EXACT}\n${WORD_FILES}" | sort -u | grep -v '^$' | while read -r f; do
    [[ -f "$f" ]] || continue
    MTIME=$(stat -c %Y "$f" 2>/dev/null || echo "$NOW")
    AGE_WEEKS=$(( (NOW - MTIME) / 604800 ))  # seconds per week
    [[ $AGE_WEEKS -lt 0 ]] && AGE_WEEKS=0

    # Exponential decay: exp(-δ * ageWeeks), clamped to [0.1, 1.0]
    # δ varies by query intent (recent=0.35, current=0.50, historical=0.05, neutral=0.17)
    DECAY=$(awk "BEGIN { d = exp(-$DECAY_RATE * $AGE_WEEKS); if (d < 0.1) d = 0.1; if (d > 1.0) d = 1.0; printf \"%.4f\", d }")

    # Maturity weight from frontmatter status field
    # active/deep-dive=1.3, stable=1.2, candidate/provisional=1.0, archived=0.7, dropped=0.4
    STATUS=$(head -20 "$f" | grep -m1 '^status:' | sed 's/status: *//' | tr -d ' "' || echo "")
    DEPTH=$(head -20 "$f" | grep -m1 '^depth:' | sed 's/depth: *//' | tr -d ' "' || echo "")
    MATURITY="1.0"
    case "$STATUS" in
      active)   MATURITY="1.3" ;;
      stable)   MATURITY="1.2" ;;
      archived) MATURITY="0.7" ;;
      dropped)  MATURITY="0.4" ;;
    esac
    # Depth bonus: deep-dive notes are more authoritative
    case "$DEPTH" in
      *deep*) MATURITY=$(awk "BEGIN { printf \"%.1f\", $MATURITY * 1.15 }") ;;
    esac

    # Term-match count as primary signal, normalized by document length
    RAW_TERM_SCORE=${FILE_SCORES["$f"]:-1}
    # Document length normalization: log2(lines) penalty for large files
    # Small files (≤50 lines) get no penalty; large files get diminishing returns
    DOC_LINES=$(wc -l < "$f" 2>/dev/null || echo 50)
    [[ $DOC_LINES -lt 10 ]] && DOC_LINES=10
    if [[ $DOC_LINES -le 50 ]]; then
      TERM_SCORE=$RAW_TERM_SCORE
    else
      # Penalize: score * (50 / docLines)^0.3 — gentle penalty for length
      TERM_SCORE=$(awk "BEGIN { printf \"%.1f\", $RAW_TERM_SCORE * (50.0 / $DOC_LINES) ^ 0.3 }")
    fi
    # Slug-match bonus: if filename contains query terms, boost relevance
    SLUG_NAME=$(basename "$f" .md)
    SLUG_BONUS=0
    SLUG_HITS=0
    for sw in $WORDS; do
      [[ ${#sw} -ge 3 ]] && [[ "$SLUG_NAME" == *"$sw"* ]] && { SLUG_BONUS=$((SLUG_BONUS + 20)); SLUG_HITS=$((SLUG_HITS + 1)); }
    done
    # Slug-priority boost: 2+ slug-term matches get a large bonus (concept card relevance)
    [[ $SLUG_HITS -ge 2 ]] && SLUG_BONUS=$((SLUG_BONUS + 100))
    # Combined: term_match * 10 + slug_bonus + decay * maturity
    SCORE=$(awk "BEGIN { printf \"%.4f\", $TERM_SCORE * 10 + $SLUG_BONUS + $DECAY * $MATURITY }")
    [[ $DEBUG -eq 1 ]] && echo "[DBG] score=$SCORE decay=$DECAY maturity=$MATURITY status=$STATUS depth=$DEPTH age=${AGE_WEEKS}w $(basename "$f")" >&2
    echo "$SCORE $f"
  done | sort -rn | cut -d' ' -f2- | head -"$LIMIT")
  
  COUNT=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    slug=$(basename "$filepath" .md)
    if [[ -z "${SEEN[$slug]+x}" ]]; then
      # Extract metadata for confidence display
      _status=$(head -20 "$filepath" | grep -m1 '^status:' | sed 's/status: *//' | tr -d ' "' || true)
      _depth=$(head -20 "$filepath" | grep -m1 '^depth:' | sed 's/depth: *//' | tr -d '"' || true)
      _verified=$(head -20 "$filepath" | grep -m1 '^last_verified:' | sed 's/last_verified: *//' | tr -d ' "' || true)
      # Build confidence badge: depth | status | verified date
      _badge=""
      [[ -n "$_depth" ]] && _badge="$_depth"
      [[ -n "$_status" ]] && { [[ -n "$_badge" ]] && _badge="$_badge | $_status" || _badge="$_status"; }
      [[ -n "$_verified" ]] && { [[ -n "$_badge" ]] && _badge="$_badge | ✓$_verified" || _badge="✓$_verified"; }
      # Show matching line for context
      match_line=$(grep -m1 -i "$QUERY" "$filepath" 2>/dev/null || grep -m1 -i "$(echo "$WORDS" | head -1)" "$filepath" 2>/dev/null || echo "(matched by keyword)")
      if [[ -n "$_badge" ]]; then
        echo "  🔍 $slug [$_badge] — $match_line"
      else
        echo "  🔍 $slug — $match_line"
      fi
      SEEN["$slug"]=1
      RESULTS+=("  🔍 $slug")
      COUNT=$((COUNT + 1))
    fi
    [[ $COUNT -ge $LIMIT ]] && break
  done <<< "$ALL_KEYWORD"
  
  [[ $COUNT -eq 0 ]] && echo "  (no additional results beyond semantic)"
  echo ""
fi

# ---- Summary ----
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Total unique results: ${#RESULTS[@]}"
if [[ ${#RESULTS[@]} -gt 0 ]]; then
  echo "  Legend: 🔮=semantic 🔍=keyword"
  for r in "${RESULTS[@]}"; do
    echo "$r"
  done
fi
