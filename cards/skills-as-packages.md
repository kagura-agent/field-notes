# Skills as Packages

> Agent skills are evolving from loose files to installable packages with metadata, versioning, and dependency management.

## 趋势证据（2026-04 观察）

三个独立项目趋同于同一方向：

| 项目 | 机制 | 包描述符 | 版本管理 |
|------|------|----------|----------|
| [[gbrain]] | manifest.json + RESOLVER.md | conformance_version, dependencies | ✅ |
| [[skillclaw]] | YAML frontmatter in SKILL.md | name, version, triggers, tools | ✅ |
| OpenClaw | skill catalog（description 隐式匹配） | 无正式包描述符 | ❌ |

## 关键架构概念

### Package Descriptor
manifest.json 包含：skill 列表（name, path, description）、依赖声明（runtime, package）、setup 入口、conformance version。这是 **npm package.json 的 skill 版本**。

### Explicit Routing (Resolver)
显式 trigger→skill 路由表替代隐式 description 匹配。GBrain 的 RESOLVER.md 约 100 行，替代了 20,000 行 mega-prompt。与 [[thin-harness-fat-skills]] 一脉相承。

### Cross-Package Composition
GBrain skills + GStack skills = complete agent。GBrain 的 RESOLVER 引用 GStack 的 thinking skills（office-hours, ceo-review, investigate, retro），通过 `detectGStack()` 做 optional dependency 检测。这是 **agent 能力从单体走向可组合模块** 的信号。

### Conformance Versioning
format 兼容性管理。GBrain 用 `conformance_version: 1.0.0` 表示 skill file 格式版本，与 skill 自身版本分离。

## 演进路径

个人工具 → 安全加固 → 平台化/模块化

GBrain: v0.8.1（search quality）→ v0.9.x（security）→ v0.10.x（GStack mod）
先让产品好用 → 再安全 → 再平台化。这个顺序可能是通用的。

## 对我们的启示

- OpenClaw skill 系统缺包级元数据——如果 skill 数量增长，需要 manifest 或等价机制
- 显式 resolver vs 隐式 description 匹配是 tradeoff：显式更省 context 但更 rigid，隐式更灵活但更贵
- 跨包组合在当前规模（~15 skills）还不紧迫，但值得关注

## 关联
- [[thin-harness-fat-skills]] — 架构基础
- [[skill-ecosystem]] — 生态视角
- [[gbrain]] — 主要证据来源
- [[skillclaw]] — 另一个独立趋同的证据

## Tags
#agent-skills #architecture #trend #packaging
