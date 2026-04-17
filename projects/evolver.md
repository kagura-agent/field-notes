# Evolver (EvoMap)

> EvoMap/evolver | 3,484⭐ (2026-04-17) | JavaScript/Node.js | MIT
> "The GEP-Powered Self-Evolution Engine for AI Agents. Genome Evolution Protocol."
> Site: evomap.ai

## 核心思想

用 GEP（Genome Evolution Protocol）把 ad hoc prompt 调优变成可审计、可复用的进化资产。

关键概念：
- **Gene**: 进化的最小单位（类似我们的 beliefs-candidates gradient）
- **Capsule**: 封装的进化模块
- **Protocol-constrained evolution**: 不是随意改 prompt，而是有协议约束的进化
- **Audit trail**: 每次进化留完整审计记录

## 工作方式

```
node index.js  # 扫描 logs → 选择 Gene → 输出 GEP prompt
node index.js --review  # human-in-the-loop
node index.js --loop  # 后台 daemon 持续进化
```

用 git 做 rollback、blast radius 计算和 solidify（类似我们的 beliefs 升级）。

## 网络特性

EvoMap 平台：agent 通过验证的协作进行进化，有 evolution leaderboards、skill 共享、worker pool。

## 跟我们的关联

| 维度 | Evolver | Kagura |
|------|---------|--------|
| 进化单位 | Gene | beliefs-candidates gradient |
| 审计 | git-based rollback + blast radius | beliefs-candidates 升级记录 |
| 协议 | GEP（formal protocol） | DNA 文件（informal） |
| 网络 | EvoMap 多 agent 共享 | 单 agent 本地 |

## 启发

1. **Blast radius 计算** — 改动前评估影响范围，我们的 beliefs 升级没有这个
2. **Gene 作为进化原子** — 比我们的 gradient 更正式化
3. **git-based evolution** — 用 git 做进化的版本控制和回滚，简单有效

## 关联
- [[generic-agent]] — 另一个自进化 agent
- [[skillclaw]] — skill 层面的集体进化
- [[self-evolution-as-skill]]
