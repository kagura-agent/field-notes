#!/usr/bin/env bash
# wiki-lint.sh — Check wiki health: broken wikilinks, orphans, duplicates
# Usage: ./scripts/wiki-lint.sh [--fix-suffix]
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WIKI_DIR"

echo "=== Wiki Lint Report ($(date -I)) ==="
echo ""

# 1. Collect all wikilink references (skip backtick-quoted refs like `[[example]]`)
grep -rn '\[\[[^]]*\]\]' cards/ projects/ 2>/dev/null \
  | grep -v 'scripts/' \
  | grep -v '`\[\[' \
  | grep -oP '\[\[[^]]+\]\]' \
  | sed 's/\[\[//;s/\]\]//' \
  | sed 's/|.*//' \
  | sed 's/#.*//' \
  | grep -v '^$' \
  | sort -u > /tmp/wiki_refs.txt

# 2. Collect all card/project slugs
(ls cards/ 2>/dev/null | sed 's/\.md$//'; ls projects/ 2>/dev/null | sed 's/\.md$//') \
  | sort -u > /tmp/wiki_slugs.txt

# 3. Find broken links (referenced but no file exists)
BROKEN=$(comm -23 /tmp/wiki_refs.txt /tmp/wiki_slugs.txt)
BROKEN_COUNT=$(echo "$BROKEN" | grep -c . || true)

echo "## Broken Wikilinks: $BROKEN_COUNT"
if [ "$BROKEN_COUNT" -gt 0 ]; then
  echo "$BROKEN" | while read -r slug; do
    echo "  ❌ [[$slug]]"
    grep -rn "\[\[$slug" cards/ projects/ 2>/dev/null | head -2 | sed 's/^/     /' || true
  done
fi
echo ""

# 4. Orphan cards (no incoming links)
echo "## Orphan Cards (no incoming links):"
ORPHAN_COUNT=0
for f in cards/*.md; do
  slug=$(basename "$f" .md)
  if ! grep -rq "\[\[$slug" cards/ projects/ 2>/dev/null; then
    echo "  🔗 $slug"
    ORPHAN_COUNT=$((ORPHAN_COUNT + 1))
  fi
done
echo "  Total: $ORPHAN_COUNT orphans"
echo ""

# 5. Duplicate slugs (same name in cards/ and projects/)
echo "## Duplicate Slugs (in both cards/ and projects/):"
DUP_COUNT=0
for f in cards/*.md; do
  slug=$(basename "$f")
  if [ -f "projects/$slug" ]; then
    echo "  ⚠️  $slug exists in both cards/ and projects/"
    DUP_COUNT=$((DUP_COUNT + 1))
  fi
done
echo "  Total: $DUP_COUNT duplicates"
echo ""

# 6. .md suffix in wikilinks (common mistake)
echo "## Links with .md suffix (should be bare slug):"
SUFFIX_LINKS=$(grep -rn '\[\[[^]]*\.md\]\]' cards/ projects/ 2>/dev/null || true)
if [ -n "$SUFFIX_LINKS" ]; then
  echo "$SUFFIX_LINKS" | head -10 | sed 's/^/  /'
else
  echo "  ✅ None found"
fi
echo ""

# 7. Staleness check (confidence decay)
echo "## Stale Files (not verified recently):"
STALE_COUNT=0
NOW=$(date +%s)
for f in cards/*.md projects/*.md; do
  # Try last_verified first, then created, then git date
  verified=$(grep -m1 'last_verified:' "$f" 2>/dev/null | sed "s/.*: *['\"]\{0,1\}//;s/['\"].*//" || true)
  if [ -z "$verified" ]; then
    verified=$(grep -m1 'created:' "$f" 2>/dev/null | sed "s/.*: *['\"]\{0,1\}//;s/['\"].*//" || true)
  fi
  if [ -z "$verified" ] || ! date -d "$verified" +%s &>/dev/null; then
    continue
  fi
  file_epoch=$(date -d "$verified" +%s 2>/dev/null || continue)
  days_old=$(( (NOW - file_epoch) / 86400 ))
  # Threshold: projects 14d, cards 30d
  threshold=30
  [[ "$f" == projects/* ]] && threshold=14
  if [ "$days_old" -gt "$threshold" ]; then
    echo "  ⏰ ${days_old}d stale: $f"
    STALE_COUNT=$((STALE_COUNT + 1))
  fi
done
echo "  Total: $STALE_COUNT stale files"
echo ""

# Summary
echo "=== Summary ==="
echo "Broken: $BROKEN_COUNT | Orphans: $ORPHAN_COUNT | Duplicates: $DUP_COUNT | Stale: $STALE_COUNT"
