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

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit) LIMIT="$2"; shift 2 ;;
    --keyword-only) MODE="keyword"; shift ;;
    --semantic-only) MODE="semantic"; shift ;;
    *) QUERY="$1"; shift ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo "Usage: bash search.sh \"<query>\" [--limit N] [--keyword-only] [--semantic-only]"
  exit 1
fi

declare -A SEEN
RESULTS=()

# ---- Semantic search (memex) ----
if [[ "$MODE" == "hybrid" || "$MODE" == "semantic" ]]; then
  echo "🔮 Semantic results (memex):"
  MEMEX_OUT=$(cd "$WIKI_DIR" && MEMEX_HOME=. memex search "$QUERY" --limit "$LIMIT" 2>/dev/null || true)
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
  WORDS=$(echo "$QUERY" | tr ' ' '\n' | grep -v -iE '^(the|a|an|is|are|was|were|with|for|and|or|not|about|more|than|that|this|from|have|has|been|will|can|could|would|should|of|in|on|at|to|by)$' || true)
  
  WORD_FILES=""
  for word in $WORDS; do
    if [[ ${#word} -ge 3 ]]; then
      found=$(grep -rli "$word" "$WIKI_DIR/projects/" "$WIKI_DIR/cards/" 2>/dev/null || true)
      if [[ -z "$WORD_FILES" ]]; then
        WORD_FILES="$found"
      elif [[ -n "$found" ]]; then
        # Intersect: files matching ALL significant words
        WORD_FILES=$(comm -12 <(echo "$WORD_FILES" | sort) <(echo "$found" | sort))
      fi
    fi
  done
  
  # Merge exact + intersection results, deduplicate, sort by recency (temporal decay)
  # Newer files rank higher — matches krusch-context-mcp temporal decay insight
  ALL_KEYWORD=$(echo -e "${EXACT}\n${WORD_FILES}" | sort -u | grep -v '^$' | while read -r f; do
    [[ -f "$f" ]] && echo "$(stat -c %Y "$f" 2>/dev/null || echo 0) $f"
  done | sort -rn | cut -d' ' -f2- | head -"$LIMIT")
  
  COUNT=0
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    slug=$(basename "$filepath" .md)
    if [[ -z "${SEEN[$slug]+x}" ]]; then
      # Show matching line for context
      match_line=$(grep -m1 -i "$QUERY" "$filepath" 2>/dev/null || grep -m1 -i "$(echo "$WORDS" | head -1)" "$filepath" 2>/dev/null || echo "(matched by keyword)")
      echo "  🔍 $slug — $match_line"
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
