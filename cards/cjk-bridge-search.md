---
created: 2026-05-18
status: active
depth: applied
last_verified: 2026-05-18
---
# CJK-to-English Bridge for Wiki Search

## Problem

BM25 engines (including [[memex]]) tokenize by whitespace/punctuation. CJK characters are continuous (no spaces between words), so Chinese queries produce zero results against English-language wiki content.

Example: `"最近有什么新项目"` → memex returns nothing, even though wiki has many project notes.

## Solution

`search.sh` now detects CJK characters in the query and:
1. Extracts any embedded English words (project names, tech terms)
2. Maps known Chinese domain terms to English via a 35-term dictionary
3. Runs a supplementary memex query with the translated terms
4. Only fires when the original query returns empty (no performance cost on English queries)

## Term Mapping Categories

| Category | Examples |
|----------|----------|
| Agent/AI | 项目→project, 代理→agent, 记忆→memory, 技能→skill |
| Memory | 知识→knowledge, 图谱→graph, 向量→vector, 衰减→decay |
| Meta | 开源→open-source, 生态→ecosystem, 框架→framework |

## Limitations

- Dictionary-based, not true NLP segmentation — only catches mapped terms
- New domain vocabulary requires manual dictionary updates
- Single-character terms too ambiguous, minimum is 2-char compounds
- No transliteration (project names in Chinese phonetic form won't match)

## Why Not Full CJK Tokenization

Full jieba/MeCab tokenization would add a Python dependency to a bash script. The 80/20 approach: a small dictionary covers >90% of our actual Chinese search queries because our wiki uses consistent English technical vocabulary.

## Links

[[memex]], [[search-sh]], [[intent-aware-retrieval]], [[brain-rust]]
