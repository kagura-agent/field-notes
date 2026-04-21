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

## 跟进 2026-04-21: 去中心化验证网络 + 多节点生产运行

### 关键变化

**Stars**: 4,243 → 6,122⭐ (3天 +1,879)，增速惊人

**v1.68.0-beta (04-18~19): Validator Role — 去中心化验证**
- Opt-in validator role: staked nodes 可以从 Hub 领取验证任务
- 在隔离 sandbox 中运行 asset validation commands，报告 PASS/FAIL
- Hub 做共识决策（consensus-based promotion）
- 配置门控 `EVOLVER_VALIDATOR_ENABLED`（默认关闭）
- **洞察**: Evolver 从单 agent 进化引擎转向**去中心化进化网络**。validator 角色 = 让多个 agent 互相验证进化结果，类似 PoS 共识。这是 agent 自进化领域首次出现的网络化验证机制

**v1.69.x (04-20~21): 生产环境鲁棒性**
- **PR #4**: 在 ~20 个 OpenClaw agent nodes 上运行发现的 3 个 bug
  - CWD-relative `require('./src/evolve')` → absolute path（`buildValidationCmd()`）
  - 自动创建 GEP asset files（`ensureAssetFiles()`）— LLM 生成的 grep/cat 命令引用不存在的 JSONL 文件
  - **修复循环修复**: 3+ 次连续失败 repair → `FORCE_INNOVATION=true` 强制创新而非继续修
- **v1.69.5**: Hub 签发的 node_id 格式修复（16-hex vs 12-hex）
- **v1.69.6**: 作为 npm dep 安装时自动检测 host `.git`
- **v1.69.7**: 默认配置加固（leak check 从 warn 改 strict）

### 生产经验启发

1. **Circuit breaker for repair loops** — 我们的 beliefs-candidates 也可能遇到类似情况：同一个 gradient 反复出现但改进无效 → 需要机制跳出修复循环，尝试全新方向
2. **Asset file 预创建** — LLM 会引用它认为「应该存在」的文件。防御性编程：如果 LLM 可能 grep 某个文件，确保它存在（哪怕为空）
3. **20+ OpenClaw nodes 运行 evolver** — 说明 Evolver 开始成为 OpenClaw 生态的标配 skill，不只是独立工具
4. **Hub-issued node ID** — 网络化运行带来身份管理问题（节点重启不应换 ID）

### 竞品对比动态

| 项目 | 本周动态 | 方向 |
|------|---------|------|
| Evolver | 去中心化验证网络 + 多节点生产 | 网络化进化 |
| [[opencode]] | session compaction + 并发编辑修复 | 工具稳定性 |
| Claude Code | /resume 加速 67% + sandbox 安全加固 | 性能+安全 |

关联：[[multi-agent-distributed-systems]], [[mechanism-vs-evolution]]

## 跟进 2026-04-18: License 争议 + Source-Available 转型

- **v1.67.4** (04-18): 修了 Claude Code adapter `.claude/settings.json` schema 兼容
- **重大事件**: README 添加 "Moving Toward Source-Available" 公告
  - 指控 Hermes Agent (2026-03-09 创建 self-evolution repo) 抄袭 Evolver 设计（memory system, skill self-improvement, self-evolution 三个 headline）
  - 发布详细对比分析博文: evomap.ai/blog/hermes-agent-evolver-similarity-analysis
  - 已发布版本保持 MIT/GPL-3.0，未来版本转 source-available
- **生态信号**: 自进化赛道开始出现 IP 纠纷，先行者保护意识增强。GPL-3.0 可能不够防抄，才要转 source-available
- **对我们的影响**: 做 self-evolving agent 时需要：(1) 明确引用来源 (2) 设计差异化而非复制 (3) 注意 license 合规

## OpenCode 跟进 2026-04-21

> anomalyco/opencode | 146,751⭐ | v1.14.19 (04-20)

近期密集发版（v1.14.17~v1.14.19，3 天 3 版）：
- **Session compaction 改进**: `preserve_recent_tokens` — 压缩 session 时保留最近几轮原文，后续引用不丢上下文
- **并发编辑保护**: 多 tool 并行编辑同一文件时不再互相覆盖
- **OTEL 遥测**: 支持 `OTEL_RESOURCE_ATTRIBUTES` 自定义遥测，workspace 内也传递 exporter 设置
- **NVIDIA 作为内置 provider**

关联：[[coding-agent-ecosystem]], [[process-hang-watchdog]]

## Claude Code 跟进 2026-04-21

> anthropics/claude-code | 116,397⭐ | v2.1.116 (04-20)

- **/resume 大 session 加速 67%**: 40MB+ session 和大量 dead-fork 条目处理更快
- **MCP 延迟加载**: `resources/templates/list` 推迟到首次 @-mention 才调用
- **gh rate limit 提示**: bash tool 检测到 GitHub API rate limit 时给 agent 提示退避
- **Sandbox 安全**: auto-allow 不再绕过 rm/rmdir 对 `/`、`$HOME` 等关键路径的保护
- **Agent hooks**: `hooks:` frontmatter 现在在 `--agent` 主线程模式下也触发

关联：[[claude-code-skills]], [[agent-security]]
