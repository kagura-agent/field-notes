# Tree-sitter

Incremental parsing library for programming languages. Generates concrete syntax trees (CSTs) from source code, enabling fast, error-tolerant parsing.

## Key Properties
- **Incremental**: Re-parses only changed portions of a file
- **Error-tolerant**: Produces valid trees even from incomplete/broken code
- **Language-agnostic**: Grammar files define each language independently
- **Zero dependencies**: C runtime, bindings for many languages (Rust, Node, Python, Go, WASM)

## Use Cases
- Syntax highlighting (used by Neovim, Zed, Helix, GitHub)
- [[agent-native-code-search]]: AST-aware code navigation for AI agents
- Code analysis, linting, refactoring tools
- Structural search/replace (e.g., `ast-grep`)

## In Agent Context
- Agents use tree-sitter for code-aware context extraction — understanding function boundaries, class hierarchies, import graphs
- More precise than regex-based grep for code understanding
- [[dirac]] uses AST-native tools built on similar principles

## Links
- GitHub: tree-sitter/tree-sitter
- Docs: tree-sitter.github.io
