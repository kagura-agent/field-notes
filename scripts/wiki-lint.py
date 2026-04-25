#!/usr/bin/env python3
"""wiki-lint.py — Systematic quality checks for the wiki.

Checks:
  1. Broken wikilinks ([[link]] pointing to non-existent files)
  2. Index consistency (index.md vs actual files)
  3. Orphan detection (files with no inbound links)
  4. Stub/empty files
  5. Duplicate slugs (same filename in different dirs)
  6. cards-index.md staleness

Usage: python3 scripts/wiki-lint.py [wiki_dir]
"""

import os
import re
import sys
from collections import defaultdict
from pathlib import Path

WIKI_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).parent.parent
os.chdir(WIKI_DIR)

errors = 0
warnings = 0

def error(msg):
    global errors; errors += 1; print(f"ERROR {msg}")
def warn(msg):
    global warnings; warnings += 1; print(f"WARN  {msg}")
def info(msg):
    print(f"INFO  {msg}")
def ok(msg):
    print(f"OK    {msg}")

# ── Build file index ──
all_files = []
slug_to_paths = defaultdict(list)  # slug -> [paths]

for root, dirs, files in os.walk('.'):
    dirs[:] = [d for d in dirs if d not in ('.git', '.memex')]
    for f in files:
        if f.endswith('.md'):
            path = os.path.join(root, f)
            all_files.append(path)
            slug = f[:-3]  # remove .md
            slug_to_paths[slug].append(path)

# Lowercase slug lookup
slug_lower_set = {s.lower() for s in slug_to_paths}

# ── 1. Broken Wikilinks ──
print("\n═══════════════════════════════════════════════════════")
print(" 1. BROKEN WIKILINKS")
print("═══════════════════════════════════════════════════════")

wikilink_re = re.compile(r'\[\[([^\]]+)\]\]')
all_wikilinks = []  # (source, target_slug)
broken_links = []

for fpath in all_files:
    try:
        content = open(fpath, 'r', errors='replace').read()
    except Exception:
        continue
    for m in wikilink_re.finditer(content):
        raw = m.group(1).strip()
        # Handle [[display|slug]] format
        if '|' in raw:
            raw = raw.split('|')[-1].strip()
        slug = raw.lower().replace(' ', '-')
        all_wikilinks.append((fpath, raw, slug))
        if slug not in slug_lower_set:
            broken_links.append((fpath, raw))

if not broken_links:
    ok("No broken wikilinks found")
else:
    # Deduplicate
    seen = set()
    unique_broken = []
    for src, link in broken_links:
        key = (src, link)
        if key not in seen:
            seen.add(key)
            unique_broken.append((src, link))

    error(f"{len(unique_broken)} broken wikilinks found:")
    errors -= 1  # counted once above, will add individual
    for src, link in sorted(unique_broken)[:60]:
        error(f"  {src} -> [[{link}]]")
    if len(unique_broken) > 60:
        info(f"  ... and {len(unique_broken) - 60} more")

# ── 2. Index Consistency ──
print("\n═══════════════════════════════════════════════════════")
print(" 2. INDEX CONSISTENCY")
print("═══════════════════════════════════════════════════════")

index_path = Path('index.md')
if index_path.exists():
    index_content = index_path.read_text(errors='replace')
    md_link_re = re.compile(r'\(([^)]*\.md)\)')

    # Files in index but missing on disk
    missing_disk = 0
    for m in md_link_re.finditer(index_content):
        ref = m.group(1)
        if not Path(ref).exists():
            error(f"index.md -> '{ref}' (file missing)")
            missing_disk += 1

    # Files not in index
    missing_index = 0
    for d in ('cards', 'projects'):
        if not Path(d).exists():
            continue
        for f in sorted(Path(d).glob('*.md')):
            if f.name not in index_content:
                warn(f"{f} not in index.md")
                missing_index += 1

    if missing_disk == 0 and missing_index == 0:
        ok("Index is consistent")
    else:
        info("Run 'bash scripts/gen-index.sh > index.md' to regenerate")
else:
    warn("No index.md found")

# ── 3. Orphan Detection ──
print("\n═══════════════════════════════════════════════════════")
print(" 3. ORPHAN DETECTION")
print("═══════════════════════════════════════════════════════")

# Build set of referenced slugs
referenced = set()

# From wikilinks
for _, _, slug in all_wikilinks:
    referenced.add(slug)

# From markdown links
md_ref_re = re.compile(r'\(([^)]*\.md)\)')
for fpath in all_files:
    try:
        content = open(fpath, 'r', errors='replace').read()
    except Exception:
        continue
    for m in md_ref_re.finditer(content):
        ref = m.group(1)
        slug = Path(ref).stem.lower()
        referenced.add(slug)

orphan_cards = []
orphan_projects = []

for d, orphan_list in [('cards', orphan_cards), ('projects', orphan_projects)]:
    if not Path(d).exists():
        continue
    for f in sorted(Path(d).glob('*.md')):
        slug = f.stem.lower()
        if slug not in referenced:
            orphan_list.append(f.stem)

total_orphans = len(orphan_cards) + len(orphan_projects)
if total_orphans == 0:
    ok("No orphan files")
else:
    warn(f"{total_orphans} orphans ({len(orphan_cards)} cards, {len(orphan_projects)} projects)")
    warnings -= 1
    if orphan_cards:
        info(f"Orphan cards ({len(orphan_cards)}):")
        for c in orphan_cards[:30]:
            warn(f"  {c}")
        if len(orphan_cards) > 30:
            info(f"  ... and {len(orphan_cards) - 30} more")
    if orphan_projects:
        info(f"Orphan projects ({len(orphan_projects)}):")
        for p in orphan_projects[:30]:
            warn(f"  {p}")
        if len(orphan_projects) > 30:
            info(f"  ... and {len(orphan_projects) - 30} more")

# ── 4. Stub Files ──
print("\n═══════════════════════════════════════════════════════")
print(" 4. STUB FILES (<3 lines or <50 bytes)")
print("═══════════════════════════════════════════════════════")

stubs = []
for d in ('cards', 'projects'):
    if not Path(d).exists():
        continue
    for f in sorted(Path(d).glob('*.md')):
        stat = f.stat()
        lines = f.read_text(errors='replace').count('\n')
        if lines < 3 or stat.st_size < 50:
            stubs.append((str(f), lines, stat.st_size))

if not stubs:
    ok("No stub files")
else:
    for path, lines, size in stubs:
        warn(f"Stub: {path} ({lines} lines, {size} bytes)")

# ── 5. Duplicate Slugs ──
print("\n═══════════════════════════════════════════════════════")
print(" 5. DUPLICATE SLUGS")
print("═══════════════════════════════════════════════════════")

dupes = {slug: paths for slug, paths in slug_to_paths.items() if len(paths) > 1}
if not dupes:
    ok("No duplicate slugs")
else:
    for slug, paths in sorted(dupes.items()):
        warn(f"Duplicate '{slug}':")
        for p in paths:
            print(f"    {p}")

# ── 6. cards-index.md Staleness ──
print("\n═══════════════════════════════════════════════════════")
print(" 6. CARDS-INDEX.MD STALENESS")
print("═══════════════════════════════════════════════════════")

ci_path = Path('cards-index.md')
if ci_path.exists():
    ci_content = ci_path.read_text(errors='replace')
    ci_slugs = set(re.findall(r'\| ([a-z][-a-z0-9_]+)', ci_content))
    actual_cards = len(list(Path('cards').glob('*.md'))) if Path('cards').exists() else 0
    info(f"cards-index.md lists ~{len(ci_slugs)} slugs, cards/ has {actual_cards} files")
    if actual_cards > len(ci_slugs) + 10:
        warn(f"cards-index.md may be stale ({actual_cards - len(ci_slugs)} cards not indexed)")
else:
    info("No cards-index.md")

# ── Summary ──
print("\n═══════════════════════════════════════════════════════")
print(" SUMMARY")
print("═══════════════════════════════════════════════════════")
cards_count = len(list(Path('cards').glob('*.md'))) if Path('cards').exists() else 0
projects_count = len(list(Path('projects').glob('*.md'))) if Path('projects').exists() else 0
print(f"Total .md files:  {len(all_files)}")
print(f"  cards/:         {cards_count}")
print(f"  projects/:      {projects_count}")
print(f"  wikilinks:      {len(all_wikilinks)}")
print()
print(f"Errors:   {errors}")
print(f"Warnings: {warnings}")
print()

if errors == 0 and warnings == 0:
    print("✨ Wiki is clean!")
elif errors == 0:
    print("⚠ Wiki has warnings but no critical errors")
else:
    print(f"❌ Wiki has {errors} errors that need attention")

sys.exit(min(errors, 1))
