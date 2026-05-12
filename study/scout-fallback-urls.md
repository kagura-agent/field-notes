# Scout Fallback URLs

When `web_search` is unavailable, use `web_fetch` on these URLs directly.

## Hacker News
- Front page: `https://news.ycombinator.com`
- HN API top stories: `https://hacker-news.firebaseio.com/v0/topstories.json`
- HN search (Algolia): `https://hn.algolia.com/api/v1/search?query=ai+agent&tags=story&numericFilters=created_at_i>UNIX_TIMESTAMP`

## GitHub (non-API fallback)
- Trending daily: `https://github.com/trending?since=daily&spoken_language_code=en`
- Trending weekly: `https://github.com/trending?since=weekly`

## Blogs & Aggregators
- Simon Willison (LLM/agent): `https://simonwillison.net/`
- The Batch (Andrew Ng): `https://www.deeplearning.ai/the-batch/`
- Latent Space podcast: `https://www.latent.space/`

## Usage
```bash
# HN search for agent-related stories from past week
WEEK_AGO=$(date -d '7 days ago' +%s)
web_fetch "https://hn.algolia.com/api/v1/search?query=ai+agent&tags=story&numericFilters=created_at_i>${WEEK_AGO}"
```

Created 2026-05-12 after noting web_search unavailability 3 consecutive sessions.
