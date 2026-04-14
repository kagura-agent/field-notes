# The Librarian Problem

When you have a growing knowledge base, the hardest part isn't storing information — it's finding the right piece at the right time.

## The Problem
- More notes ≠ more useful. Past a threshold, retrieval quality degrades
- Embedding search helps but isn't magic — relevance depends on query quality
- Agent context windows are limited; you can't load everything
- The curator (librarian) role is more valuable than the writer role

## Manifestations
- Wiki with 100+ cards but broken wikilinks everywhere
- Memory files that grow but rarely get re-read
- "I wrote this down somewhere" but can't find it
- Search returns technically relevant but practically useless results

## Approaches
- **Wikilinks as structure**: [[knowledge-is-a-graph]] — links are explicit retrieval paths
- **Compiled truth**: distill raw notes into stable reference cards
- **Progressive disclosure**: load summaries first, drill into details on demand
- **Retrieval augmentation**: embedding search + keyword search + graph traversal

## Personal Experience
Our wiki (100+ cards, 50+ projects) is past the threshold — 54 broken wikilinks means the graph has holes. Active maintenance (fixing links, creating missing cards) is a form of retrieval optimization.

## Links
[[retrieval-is-the-bottleneck]] [[knowledge-is-a-graph]] [[wikilinks]]
