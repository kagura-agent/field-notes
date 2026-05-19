#!/bin/bash
# overlap-detector.sh — Find potentially redundant wiki notes via word overlap
# Source: Statewave conflict resolution pattern (word-overlap similarity ≥0.6
#         within same subject group → newer supersedes older)
# Applied: 2026-05-19
#
# Strategy: Index-first approach to avoid O(n²) full comparison.
# 1. Extract title keywords from each note
# 2. Build inverted index (word → notes containing it)
# 3. Only compare notes sharing 3+ title words (candidate pairs)
# 4. Compute Jaccard on candidates only
#
# Usage: bash overlap-detector.sh [--threshold 0.4] [--top 20]

WIKI_DIR="$HOME/.openclaw/workspace/wiki"
THRESHOLD="${1:-0.4}"
TOP="${2:-20}"

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --threshold) THRESHOLD="$2"; shift 2;;
    --top) TOP="$2"; shift 2;;
    *) shift;;
  esac
done

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

STOPWORDS="the|a|an|is|are|was|were|be|been|have|has|had|do|does|did|will|would|could|should|can|for|and|or|but|in|on|at|to|from|by|with|of|as|this|that|it|its|not|no|so|if|then|than|more|less|just|also|only|into|about|each|all|some|what|which|who|when|where|how|why|their|them|they|his|her|she|he|we|our|you|your|my|up|out|new|one|two|like|use|used|using|get|set|make|based|via|per|may|been|being|such|most|both|other|these|those|over|between|through|during|after|before|here|there|very|own|same|first|last|next|still"

echo "🔍 Wiki Overlap Detector (threshold ≥ $THRESHOLD)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Step 1: Extract keywords per note (title + first heading content)
note_count=0
find "$WIKI_DIR/cards" "$WIKI_DIR/projects" -name "*.md" -type f 2>/dev/null | sort | while read -r file; do
  slug=$(basename "$file" .md)
  # Extract: title from frontmatter or first # heading, plus first 3 content lines
  {
    # Get title field and first heading
    grep -m1 "^title:" "$file" 2>/dev/null | sed 's/^title:\s*["]*//;s/["]*$//'
    grep -m1 "^# " "$file" 2>/dev/null | sed 's/^# //'
    # First 5 non-empty, non-frontmatter content lines
    awk 'BEGIN{fm=0;c=0} /^---/{fm=!fm;next} fm{next} /^$/{next} /^#/{next} /^\|/{next} /^>/{next} {print;c++;if(c>=5)exit}' "$file"
  } | tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9 ]/ /g' | tr -s ' ' '\n' | \
    grep -vxE "($STOPWORDS)" | \
    grep -E '.{3,}' | sort -u > "$TMPDIR/$slug.words"
done

# Count files
note_count=$(ls "$TMPDIR"/*.words 2>/dev/null | wc -l)
echo "Indexed $note_count notes."

# Step 2: Build inverted index and find candidate pairs (sharing 3+ words)
# Use awk for speed
echo "Building inverted index..."

# Create word→slug mapping
for wfile in "$TMPDIR"/*.words; do
  slug=$(basename "$wfile" .words)
  while read -r word; do
    echo "$word $slug"
  done < "$wfile"
done > "$TMPDIR/index.txt"

# Find candidate pairs: notes sharing 3+ words
echo "Finding candidate pairs..."

# For each word, find all slugs that have it, then emit all pairs
# Filter out words appearing in >20 notes (too common = noise)
awk '{print $1, $2}' "$TMPDIR/index.txt" | sort | \
awk '{
  if ($1 != prev) {
    if (n >= 2 && n <= 20) {
      for (i=1; i<=n; i++)
        for (j=i+1; j<=n; j++) {
          a = slugs[i]; b = slugs[j]
          if (a > b) { tmp=a; a=b; b=tmp }
          print a, b
        }
    }
    n=0; prev=$1
  }
  slugs[++n] = $2
}
END {
  if (n >= 2 && n <= 20) {
    for (i=1; i<=n; i++)
      for (j=i+1; j<=n; j++) {
        a = slugs[i]; b = slugs[j]
        if (a > b) { tmp=a; a=b; b=tmp }
        print a, b
      }
  }
}' | sort | uniq -c | sort -rn | awk '$1 >= 3 {print $2, $3, $1}' > "$TMPDIR/candidates.txt"

cand_count=$(wc -l < "$TMPDIR/candidates.txt")
echo "Found $cand_count candidate pairs (≥3 shared words)."
echo ""

# Step 3: Compute Jaccard similarity on candidates
echo "Computing Jaccard similarity..."
{
while read -r slug1 slug2 shared_count; do
  f1="$TMPDIR/$slug1.words"
  f2="$TMPDIR/$slug2.words"
  [[ ! -f "$f1" || ! -f "$f2" ]] && continue
  
  intersection=$(comm -12 "$f1" "$f2" | wc -l)
  total1=$(wc -l < "$f1")
  total2=$(wc -l < "$f2")
  union=$((total1 + total2 - intersection))
  
  [[ $union -eq 0 ]] && continue
  
  score=$(awk "BEGIN {printf \"%.3f\", $intersection / $union}")
  
  if awk "BEGIN {exit !($score >= $THRESHOLD)}"; then
    echo "$score|$slug1|$slug2|$intersection"
  fi
done < "$TMPDIR/candidates.txt"
} | sort -t'|' -k1 -rn | head -n "$TOP" > "$TMPDIR/results.txt"

result_count=$(wc -l < "$TMPDIR/results.txt")

if [[ $result_count -eq 0 ]]; then
  echo "No overlapping pairs found above threshold $THRESHOLD."
  exit 0
fi

echo ""
echo "Top $TOP overlapping pairs:"
echo ""
printf "%-7s | %-35s | %-35s | Shared\n" "Jaccard" "Note A" "Note B"
printf "%-7s-+-%-35s-+-%-35s-+------\n" "-------" "-----------------------------------" "-----------------------------------"

while IFS='|' read -r score slug1 slug2 shared; do
  printf "%-7s | %-35s | %-35s | %s\n" "$score" "$slug1" "$slug2" "$shared"
done < "$TMPDIR/results.txt"

echo ""
echo "Actions: merge (combine into one), supersede (keep newer, retire older), ignore (false positive)"
