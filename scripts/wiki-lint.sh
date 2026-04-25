#!/usr/bin/env bash
# wiki-lint.sh — Systematic quality checks for the wiki
set -euo pipefail

WIKI_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$WIKI_DIR"

ERRORS=0
WARNINGS=0

error() { ((ERRORS++)) || true; echo "ERROR $1"; }
warn()  { ((WARNINGS++)) || true; echo "WARN  $1"; }
info()  { echo "INFO  $1"; }
ok()    { echo "OK    $1"; }

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Build file list
find . -name "*.md" -not -path "./.git/*" -not -path "./.memex/*" > "$TMPDIR/all_files.txt"

# Build slug map: slug -> path
while IFS= read -r f; do
  slug=$(basename "$f" .md)
  echo "$slug $f"
done < "$TMPDIR/all_files.txt" > "$TMPDIR/slug_map.txt"

# Extract all slugs (lowercase for matching)
awk '{print tolower($1)}' "$TMPDIR/slug_map.txt" | sort -u > "$TMPDIR/all_slugs.txt"

# ─── 1. Broken Wikilinks ────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 1. BROKEN WIKILINKS"
echo "═══════════════════════════════════════════════════════"

# Extract all [[link]] with source file
grep -rn '\[\[' --include="*.md" . 2>/dev/null | grep -v '.git/' | grep -v '.memex/' | \
  grep -oP '(?<=[^/])[^:]+:\d+:.*?\[\[\K[^\]]+' | sort -u > "$TMPDIR/raw_links.txt" 2>/dev/null || true

# Better extraction: file:link pairs
> "$TMPDIR/wikilinks.txt"
while IFS= read -r f; do
  grep -oP '\[\[\K[^\]]+' "$f" 2>/dev/null | while read -r link; do
    echo "$f|$link"
  done
done < "$TMPDIR/all_files.txt" >> "$TMPDIR/wikilinks.txt"

BROKEN=0
BROKEN_LIST=""
sort -u "$TMPDIR/wikilinks.txt" | while IFS='|' read -r src link; do
  # Normalize link to slug
  slug=$(echo "$link" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//;s/ *$//' | tr ' ' '-')
  if ! grep -qx "$slug" "$TMPDIR/all_slugs.txt"; then
    echo "ERROR $src -> [[$link]]"
  fi
done > "$TMPDIR/broken_links.txt" 2>/dev/null || true

BROKEN=$(wc -l < "$TMPDIR/broken_links.txt")
if [[ $BROKEN -eq 0 ]]; then
  ok "No broken wikilinks found"
else
  ERRORS=$((ERRORS + BROKEN))
  echo "Found $BROKEN broken wikilinks:"
  cat "$TMPDIR/broken_links.txt" | head -50
  [[ $BROKEN -gt 50 ]] && echo "  ... and $((BROKEN - 50)) more"
fi

# ─── 2. Index Consistency ───────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 2. INDEX CONSISTENCY"
echo "═══════════════════════════════════════════════════════"

if [[ -f index.md ]]; then
  # Files referenced in index but missing
  MISSING_DISK=0
  grep -oP '\([^)]*\.md\)' index.md | sed 's/[()]//g' | sort -u | while read -r ref; do
    if [[ ! -f "$ref" ]]; then
      echo "ERROR index.md -> '$ref' (file missing)"
    fi
  done > "$TMPDIR/index_missing.txt" 2>/dev/null || true
  MISSING_DISK=$(wc -l < "$TMPDIR/index_missing.txt")
  
  # Files not in index
  MISSING_INDEX=0
  > "$TMPDIR/index_unlisted.txt"
  for dir in cards projects; do
    [[ ! -d "$dir" ]] && continue
    for f in "$dir"/*.md; do
      [[ ! -f "$f" ]] && continue
      bn=$(basename "$f")
      if ! grep -q "$bn" index.md 2>/dev/null; then
        echo "WARN  $f not listed in index.md" >> "$TMPDIR/index_unlisted.txt"
        ((MISSING_INDEX++)) || true
      fi
    done
  done
  
  if [[ $MISSING_DISK -eq 0 && $MISSING_INDEX -eq 0 ]]; then
    ok "Index is consistent"
  else
    [[ $MISSING_DISK -gt 0 ]] && { ERRORS=$((ERRORS + MISSING_DISK)); cat "$TMPDIR/index_missing.txt"; }
    [[ $MISSING_INDEX -gt 0 ]] && { WARNINGS=$((WARNINGS + MISSING_INDEX)); cat "$TMPDIR/index_unlisted.txt" | head -30; }
    info "Run 'bash scripts/gen-index.sh > index.md' to regenerate"
  fi
fi

# ─── 3. Orphan Detection ───────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 3. ORPHAN DETECTION (cards/projects with no inbound links)"
echo "═══════════════════════════════════════════════════════"

# Collect all referenced slugs (from wikilinks + md links + index)
{
  # Wikilinks
  awk -F'|' '{print $2}' "$TMPDIR/wikilinks.txt" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/^ *//;s/ *$//'
  # Markdown links
  grep -roh '([^)]*\.md)' --include="*.md" . 2>/dev/null | grep -v '.git/' | sed 's/[()]//g' | xargs -I{} basename {} .md | tr '[:upper:]' '[:lower:]'
} | sort -u > "$TMPDIR/referenced_slugs.txt"

ORPHAN_CARDS=0
ORPHAN_PROJECTS=0
> "$TMPDIR/orphans.txt"
for dir in cards projects; do
  [[ ! -d "$dir" ]] && continue
  for f in "$dir"/*.md; do
    [[ ! -f "$f" ]] && continue
    slug=$(basename "$f" .md)
    slug_lower=$(echo "$slug" | tr '[:upper:]' '[:lower:]')
    if ! grep -qx "$slug_lower" "$TMPDIR/referenced_slugs.txt"; then
      echo "$dir/$slug" >> "$TMPDIR/orphans.txt"
      if [[ "$dir" == "cards" ]]; then
        ((ORPHAN_CARDS++)) || true
      else
        ((ORPHAN_PROJECTS++)) || true
      fi
    fi
  done
done

ORPHAN_TOTAL=$((ORPHAN_CARDS + ORPHAN_PROJECTS))
if [[ $ORPHAN_TOTAL -eq 0 ]]; then
  ok "No orphan files"
else
  WARNINGS=$((WARNINGS + ORPHAN_TOTAL))
  echo "WARN  $ORPHAN_TOTAL orphans ($ORPHAN_CARDS cards, $ORPHAN_PROJECTS projects)"
  cat "$TMPDIR/orphans.txt" | sort | head -40
  [[ $ORPHAN_TOTAL -gt 40 ]] && echo "  ... and $((ORPHAN_TOTAL - 40)) more"
fi

# ─── 4. Empty / Stub Files ──────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 4. EMPTY / STUB FILES (<3 lines or <50 bytes)"
echo "═══════════════════════════════════════════════════════"

STUB_COUNT=0
> "$TMPDIR/stubs.txt"
for dir in cards projects; do
  [[ ! -d "$dir" ]] && continue
  for f in "$dir"/*.md; do
    [[ ! -f "$f" ]] && continue
    lines=$(wc -l < "$f")
    chars=$(wc -c < "$f")
    if [[ $lines -lt 3 || $chars -lt 50 ]]; then
      echo "WARN  Stub: $f ($lines lines, $chars bytes)" >> "$TMPDIR/stubs.txt"
      ((STUB_COUNT++)) || true
    fi
  done
done

if [[ $STUB_COUNT -eq 0 ]]; then
  ok "No stub files"
else
  WARNINGS=$((WARNINGS + STUB_COUNT))
  cat "$TMPDIR/stubs.txt"
fi

# ─── 5. Duplicate Slugs ─────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 5. DUPLICATE SLUGS"
echo "═══════════════════════════════════════════════════════"

DUPES=$(awk '{print $1}' "$TMPDIR/slug_map.txt" | sort | uniq -d)
if [[ -z "$DUPES" ]]; then
  ok "No duplicate slugs"
else
  echo "$DUPES" | while read -r dup; do
    locs=$(grep "^$dup " "$TMPDIR/slug_map.txt" | awk '{print $2}')
    echo "WARN  Duplicate '$dup':"
    echo "$locs" | sed 's/^/    /'
    ((WARNINGS++)) || true
  done
fi

# ─── 6. cards-index.md Consistency ──────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " 6. CARDS-INDEX.MD vs ACTUAL CARDS"
echo "═══════════════════════════════════════════════════════"

if [[ -f cards-index.md ]]; then
  CARDS_INDEXED=$(grep -oP '\| [a-z][-a-z0-9_]+' cards-index.md | sed 's/| //' | sort -u | wc -l)
  CARDS_ACTUAL=$(ls cards/*.md 2>/dev/null | wc -l)
  echo "INFO  cards-index.md lists ~$CARDS_INDEXED slugs, cards/ has $CARDS_ACTUAL files"
  if [[ $CARDS_ACTUAL -gt $((CARDS_INDEXED + 10)) ]]; then
    warn "cards-index.md may be stale ($((CARDS_ACTUAL - CARDS_INDEXED)) cards not indexed)"
  fi
fi

# ─── Summary ────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════"
echo " SUMMARY"
echo "═══════════════════════════════════════════════════════"
TOTAL_FILES=$(wc -l < "$TMPDIR/all_files.txt")
CARDS_COUNT=$(find cards/ -name "*.md" 2>/dev/null | wc -l)
PROJECTS_COUNT=$(find projects/ -name "*.md" 2>/dev/null | wc -l)

echo "Total .md files:  $TOTAL_FILES"
echo "  cards/:         $CARDS_COUNT"
echo "  projects/:      $PROJECTS_COUNT"
echo ""
echo "Errors:   $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
  echo "✨ Wiki is clean!"
elif [[ $ERRORS -eq 0 ]]; then
  echo "⚠ Wiki has warnings but no critical errors"
else
  echo "❌ Wiki has $ERRORS errors that need attention"
fi
