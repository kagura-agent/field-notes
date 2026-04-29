# Thin Harness, Fat Skills

> 架构原则: 让 harness 薄（~200 行），让 skills 厚（domain 知识 + 判断 + 流程）。

## 核心框架（5 定义）

来自 [[gbrain]] Garry Tan 的 YC Spring 2026 演讲。

1. **Skill File** — markdown IS code。一个 skill 就是一次方法调用：参数不同，能力不同。`/investigate` 传医学数据集 = 医学分析师，传 FEC 档案 = 法证调查员。
2. **Harness** — 薄层（~200 行）。只做 4 件事：run LLM loop, read/write files, manage context, enforce safety。
3. **Resolver** — context 路由表。task type X → load document Y。消除 mega-CLAUDE.md（20,000 行 → 200 行指针）。
4. **Latent vs Deterministic** — 判断归模型（latent space），计算归代码（deterministic）。LLM 能排 8 人座位，排 800 人就 hallucinate。
5. **Diarization** — 模型读 50 篇文档写 1 页结构化判断。No RAG pipeline can produce this。

## 反模式

- **Fat harness, thin skills**: 40+ tool definitions 吃半个 context window。God tools with 2-5s MCP round-trips。REST API wrappers for every endpoint。
- **解法**: 例如 Playwright CLI (100ms/op) 替代 Chrome MCP (15s/op)，75x faster。

## 自学习闭环

`/improve` skill 读反馈 → 提取规则 → 写回 skill file → 下次运行自动用新规则。YC Startup School: 12% "OK" → 4% "OK"。

**这是 skill 自进化的生产级案例** — 对应我们的 beliefs-candidates → DNA 升级管线，但 GBrain 是写回 skill file 而非 DNA。

## 跨项目关联

- [[gbrain]]: 原始出处，14,700+ brain files 规模的生产验证
- [[skillclaw]]: conservative editing protocol 是 fat skills 的另一种保护（小心修改 skill）
- [[openclaw-architecture]]: OpenClaw skill 系统 = 这个框架的一个实现
- [[skill-ecosystem]]: skill 生态 = 方法调用的 marketplace

## 对我们的启发

我们的架构已经是 thin harness + fat skills 的形态（OpenClaw + SKILL.md），但缺：
- **Resolver 显式化**: 目前靠 skill description 隐式匹配，可以更显式
- **MECE ownership**: 哪个 skill owns 哪个 entity type / signal source，没有明确 ownership table
- **5-step development cycle**: skill 开发偏 ad hoc，缺少 manual prototype → evaluate → codify 的正式流程

## 2026-04-29 Update: Open Design as design-domain instance

[[open-design]] (nexu-io/open-design, ⭐1900+ in 24h) is a clean instance of this pattern for design artifacts:
- **Thin harness**: daemon is ~300 lines (agents.js adapters + server.js), does only: detect agent CLI on PATH, spawn one-shot, pipe stdio, serve preview iframe
- **Fat skills**: 29 SKILL.md files carry all design intelligence — layout rules, self-critique checklists, brand-asset protocols, discovery question forms
- **Resolver equivalent**: `od.mode` frontmatter field routes skills to UI categories (prototype/deck/template). Less explicit than GBrain's RESOLVER.md but functional
- **Novel extension**: `od.design_system.sections` field prunes injected context to only relevant sections — a token-saving pattern applicable beyond design

Notable: OD's adapter layer is even thinner than GBrain's — each adapter is just bin name + buildArgs function + stream format hint (~10 lines). All intelligence lives in the prompt stack (discovery.ts) and skill files.

## Tags
#architecture #agent-skills #design-pattern #self-evolving
