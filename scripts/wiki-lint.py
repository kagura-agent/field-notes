#!/usr/bin/env python3
"""wiki-lint.py — Systematic quality checks for the wiki.

Checks:
  1. Broken wikilinks ([[link]] pointing to non-existent files)
  2. Index consistency (index.md vs actual files)
  3. Orphan detection (files with no inbound links)
  4. Stub/empty files
  5. Duplicate slugs (same filename in different dirs)
  6. cards-index.md staleness
  7. Frontmatter consistency
  8. Link density stats
  9. Secret scanning
  10. Staleness / confidence decay (last_verified)

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
code_block_re = re.compile(r'```.*?```', re.DOTALL)
inline_code_re = re.compile(r'`[^`]+`')
all_wikilinks = []  # (source, target_slug)
broken_links = []

def strip_code_blocks(text):
    """Remove fenced code blocks and inline code to avoid false positives."""
    text = code_block_re.sub('', text)
    text = inline_code_re.sub('', text)
    return text

for fpath in all_files:
    try:
        content = open(fpath, 'r', errors='replace').read()
    except Exception:
        continue
    clean_content = strip_code_blocks(content)
    for m in wikilink_re.finditer(clean_content):
        raw = m.group(1).strip()
        # Skip anchors-only links like [[#section]]
        if raw.startswith('#'):
            continue
        # Handle [[slug|display]] format (slug is first part)
        if '|' in raw:
            raw = raw.split('|')[0].strip()
        # Strip .md suffix if present
        if raw.endswith('.md'):
            raw = raw[:-3]
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
    md_link_re = re.compile(r'\]\(([^)]*\.md)\)')

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
    clean = strip_code_blocks(content)
    for m in md_ref_re.finditer(clean):
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

# ── 7. Frontmatter Consistency ──
print("\n═══════════════════════════════════════════════════════")
print(" 7. FRONTMATTER CONSISTENCY (cards)")
print("═══════════════════════════════════════════════════════")

frontmatter_re = re.compile(r'^---\s*\n(.*?)\n---', re.DOTALL)
missing_fm = []
if Path('cards').exists():
    for f in sorted(Path('cards').glob('*.md')):
        text = f.read_text(errors='replace')
        m = frontmatter_re.match(text)
        issues = []
        if not m:
            issues.append('no frontmatter')
        else:
            fm = m.group(1)
            if 'title:' not in fm:
                issues.append('no title')
            if 'created:' not in fm:
                issues.append('no created date')
        if issues:
            missing_fm.append((f.stem, ', '.join(issues)))

if not missing_fm:
    ok("All cards have title + created frontmatter")
else:
    warn(f"{len(missing_fm)} cards with frontmatter issues:")
    warnings -= 1
    for slug, issue in missing_fm[:20]:
        warn(f"  {slug}: {issue}")
    if len(missing_fm) > 20:
        info(f"  ... and {len(missing_fm) - 20} more")

# ── 8. Link Density Stats ──
print("\n═══════════════════════════════════════════════════════")
print(" 8. LINK DENSITY")
print("═══════════════════════════════════════════════════════")

links_per_file = defaultdict(int)
for src, _, _ in all_wikilinks:
    links_per_file[src] += 1

if links_per_file:
    vals = list(links_per_file.values())
    avg = sum(vals) / len(vals)
    info(f"Average wikilinks per linked file: {avg:.1f}")
    zero_link_cards = [f for f in all_files if f.startswith('./cards/') and f not in links_per_file]
    info(f"Cards with zero outbound links: {len(zero_link_cards)}")
    if len(zero_link_cards) <= 10:
        for c in zero_link_cards:
            warn(f"  No outbound links: {c}")


# ── 9. Secret Scanning ──
print("\n═══════════════════════════════════════════════════════")
print(" 9. SECRET SCANNING")
print("═══════════════════════════════════════════════════════")

# ~25 credential patterns inspired by gitleaks/trufflehog/Harmonist
SECRET_PATTERNS = [
    # AWS
    (r'AKIA[A-Z0-9]{16}', 'AWS Access Key ID'),
    (r'(?:aws).{0,20}(?:secret|key).{0,20}[\'"][A-Za-z0-9/+=]{40}[\'"]', 'AWS Secret Key'),
    # GitHub
    (r'ghp_[A-Za-z0-9]{36,}', 'GitHub PAT (classic)'),
    (r'gho_[A-Za-z0-9]{36,}', 'GitHub OAuth Token'),
    (r'ghs_[A-Za-z0-9]{36,}', 'GitHub App Token'),
    (r'github_pat_[A-Za-z0-9_]{22,}', 'GitHub Fine-grained PAT'),
    # OpenAI / LLM providers
    (r'sk-[A-Za-z0-9]{48,}', 'OpenAI API Key'),
    (r'sk-proj-[A-Za-z0-9\-_]{48,}', 'OpenAI Project Key'),
    # Stripe
    (r'sk_live_[A-Za-z0-9]{24,}', 'Stripe Secret Key'),
    (r'rk_live_[A-Za-z0-9]{24,}', 'Stripe Restricted Key'),
    # Slack
    (r'xoxb-[0-9]{10,}-[A-Za-z0-9]{24,}', 'Slack Bot Token'),
    (r'xoxp-[0-9]{10,}-[A-Za-z0-9]{24,}', 'Slack User Token'),
    (r'xoxs-[0-9]{10,}-[A-Za-z0-9]{24,}', 'Slack Session Token'),
    # Google
    (r'AIza[A-Za-z0-9_\-]{35}', 'Google API Key'),
    # Telegram
    (r'[0-9]{8,10}:[A-Za-z0-9_-]{35}', 'Telegram Bot Token'),
    # Discord
    (r'[MN][A-Za-z0-9]{23,}\.[A-Za-z0-9_-]{6}\.[A-Za-z0-9_-]{27,}', 'Discord Bot Token'),
    # npm
    (r'npm_[A-Za-z0-9]{36,}', 'npm Access Token'),
    # PyPI
    (r'pypi-[A-Za-z0-9]{50,}', 'PyPI API Token'),
    # Private keys
    (r'-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY', 'Private Key'),
    # Generic high-entropy secrets in assignments
    (r'(?:password|passwd|secret|token|apikey|api_key)\s*[:=]\s*[\'"][^\s\'"]{16,}[\'"]', 'Generic Secret Assignment'),
    # Heroku
    (r'heroku.{0,10}[A-Fa-f0-9]{8}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{4}-[A-Fa-f0-9]{12}', 'Heroku API Key'),
    # Twilio
    (r'SK[A-Fa-f0-9]{32}', 'Twilio API Key'),
    # Mailgun
    (r'key-[A-Za-z0-9]{32}', 'Mailgun API Key'),
    # SendGrid
    (r'SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}', 'SendGrid API Key'),
    # Age encryption key (private)
    (r'AGE-SECRET-KEY-[A-Z0-9]{59}', 'Age Secret Key'),
]

compiled_secrets = [(re.compile(pat), name) for pat, name in SECRET_PATTERNS]
secret_findings = []

for fpath in all_files:
    try:
        content = open(fpath, 'r', errors='replace').read()
    except Exception:
        continue
    # Skip code blocks (patterns in examples/docs are less likely real)
    clean = strip_code_blocks(content)
    for line_no, line in enumerate(clean.splitlines(), 1):
        for pat, name in compiled_secrets:
            if pat.search(line):
                # Avoid false positives: skip lines that look like documentation/examples
                line_stripped = line.strip()
                if any(fp in line_stripped.lower() for fp in [
                    'example', 'placeholder', 'xxx', 'your_', 'changeme',
                    'dummy', 'fake', 'sample', 'test_', '<your',
                    'pattern', 'regex', 'r\'', 'r"', 'compiled',
                ]):
                    continue
                secret_findings.append((fpath, line_no, name, line_stripped[:80]))
                break  # one match per line is enough

if not secret_findings:
    ok("No credential patterns detected")
else:
    error(f"{len(secret_findings)} potential secrets found:")
    errors -= 1  # counted once above
    for fpath, line_no, name, preview in secret_findings[:30]:
        error(f"  {fpath}:{line_no} [{name}] {preview[:60]}...")
    if len(secret_findings) > 30:
        info(f"  ... and {len(secret_findings) - 30} more")
    info("Review these — some may be false positives in documentation")

# ── 10. Staleness Check (Confidence Decay) ──
print("\n═══════════════════════════════════════════════════════")
print(" 10. STALENESS CHECK (last_verified / created)")
print("═══════════════════════════════════════════════════════")

from datetime import datetime, date as date_type

today = date_type.today()

# Thresholds per card type (days)
STALENESS_THRESHOLDS = {
    'projects': 14,   # Projects ship fast, assessments go stale
    'cards': 30,      # Abstractions age slower
}
# Pattern-tagged cards get 60 days, checked below

stale_files = []

for d, threshold in STALENESS_THRESHOLDS.items():
    dpath = Path(d)
    if not dpath.exists():
        continue
    for f in sorted(dpath.glob('*.md')):
        try:
            text = f.read_text(errors='replace')
        except Exception:
            continue

        # Look for last_verified first, then created in frontmatter
        verified_date = None
        fm_match = frontmatter_re.match(text)
        threshold_used = threshold
        if fm_match:
            fm = fm_match.group(1)
            # Check last_verified first
            lv = re.search(r'last_verified:\s*(\d{4}-\d{2}-\d{2})', fm)
            if lv:
                verified_date = lv.group(1)
            else:
                cr = re.search(r'created:\s*(\d{4}-\d{2}-\d{2})', fm)
                if cr:
                    verified_date = cr.group(1)

            # Pattern-tagged cards get 60-day threshold
            if 'pattern' in fm.lower():
                threshold_used = 60
        
        if not verified_date:
            continue  # Can't check without a date

        try:
            vdate = datetime.strptime(verified_date, '%Y-%m-%d').date()
            days_old = (today - vdate).days
            if days_old > threshold_used:
                stale_files.append((str(f), days_old, threshold_used, verified_date))
        except ValueError:
            continue

if not stale_files:
    ok("No stale files detected")
else:
    # Sort by staleness (most stale first)
    stale_files.sort(key=lambda x: -x[1])
    warn(f"{len(stale_files)} stale files (past threshold):")
    warnings -= 1
    for fpath, days, thresh, vdate in stale_files[:30]:
        warn(f"  {fpath} — {days}d old (threshold {thresh}d, date {vdate})")
    if len(stale_files) > 30:
        info(f"  ... and {len(stale_files) - 30} more")
    info("Update content + set 'last_verified: YYYY-MM-DD' in frontmatter to clear")

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
