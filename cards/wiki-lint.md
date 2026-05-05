---
title: Wiki Lint
tags: [tooling, wiki, quality]
created: 2026-05-05
---

# Wiki Lint

A Python script (`wiki-lint.py`) for automated wiki health checks.

## Checks

1. **Frontmatter validation**: required fields (title, tags, created)
2. **Link density**: detects cards that are too isolated or over-linked
3. **Content quality**: minimum length, heading structure
4. **Secret scanning**: 25 credential patterns (API keys, tokens, passwords)
5. **Orphan detection**: cards with no inbound or outbound links

## Usage

```bash
python3 wiki-lint.py [wiki-dir]
```

## History

- 2026-04-27: Created with frontmatter + link-density checks
- 2026-04-28: Added secret scanning (25 patterns, zero false positives on 493 files)

## See Also

- [[wikilinks]] — the linking system wiki-lint validates
- [[agent-safety]] — security context for secret scanning
