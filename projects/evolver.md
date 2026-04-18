# Evolver (EvoMap)

> EvoMap/evolver | 4,243⭐ (2026-04-18, +759/天) | JavaScript/Node.js | MIT
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

## 代码深读 (2026-04-18)

### 核心代码混淆
`src/evolve.js` 被混淆，说明这是商业化产品。周边模块（tests、adapters、scripts）开源。

### GEP Gene 结构（genes.json）
每个 Gene 包含：
- `signals_match`: 触发词列表（error/protocol/user_feature_request 等）
- `preconditions`: 前置条件
- `strategy`: 执行策略（6 步标准流程）
- `constraints`: max_files + forbidden_paths
- `validation`: 验证命令列表

### Solidify 学习机制
- `classifyFailureMode()`: soft（validation 失败，可重试）vs hard（约束违反，不可重试）
- `adaptGeneFromLearning()`: 成功时把 learning signals 加入 signals_match，失败时记录 anti-pattern 但不扩展匹配
- Gene 自我进化：成功增加触发词，失败收缩

### Blast Radius 计算（policyCheck.js）
- HARD_CAP_FILES/LINES 硬上限
- isCriticalProtectedPath: MEMORY.md、.env、package.json 受保护
- excludePrefixes/includeExtensions 精细控制计数范围

### Adapters
支持 Claude Code、Codex、Cursor 作为执行后端。

## 重大事件 (2026-04-18)

### 转向 Source-Available + 指控 Hermes 抄袭

Evolver 在 README 中加入公告：**future releases 将从 GPL-3.0 open source 转为 source-available**。

原因：指控 Hermes Agent (Nous Research) 的自进化系统与 Evolver 高度相似，且未给 attribution。
- Evolver: 2026-02-01 公开，02-04 GEP 协议成型
- Hermes self-evolution repo: 2026-03-09 创建，晚 5+ 周
- Evolver 发布详细对比分析博文：evomap.ai/blog/hermes-agent-evolver-similarity-analysis
- 三个核心争议点：memory system、skill self-improvement、self-evolution positioning

**对我们的意义：**
1. 自进化 agent 领域开始出现 IP 争议，说明这个方向已进入竞争期
2. Evolver 转 source-available 可能影响社区贡献意愿
3. 我们的 beliefs-candidates 管线虽然灵感来源不同（实践演化而非模仿），但要注意保持独立演化路径的清晰性
4. 已发布的 MIT/GPL 版本不受影响

### GenericAgent 发布技术报告

GenericAgent 发布了 Technical Report PDF（assets/GenericAgent_Technical_Report.pdf, ~3.2MB）。未能成功提取文本（大文件通过 API 下载损坏）。TODO: 找到可读版本后深读。

## 启发

1. **Blast radius 计算** — 改动前评估影响范围，我们的 beliefs 升级没有这个
2. **Gene 作为进化原子** — 比我们的 gradient 更正式化
3. **git-based evolution** — 用 git 做进化的版本控制和回滚，简单有效

## 关联
- [[generic-agent]] — 另一个自进化 agent
- [[skillclaw]] — skill 层面的集体进化
- [[self-evolution-as-skill]]
