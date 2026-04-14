# Context Budget Baseline — 2026-04-14

> Kagura workspace files 注入量的首次量化 baseline，用于跟踪瘦身进展。

## 1. Baseline 指标

| 文件 | 行数 | 字符数 | 估算 tokens¹ |
|------|------|--------|-------------|
| SOUL.md | 55 | 3,811 | ~1,089 |
| AGENTS.md | 303 | 15,523 | ~4,435 |
| IDENTITY.md | 8 | 336 | ~96 |
| USER.md | 13 | 366 | ~105 |
| TOOLS.md | 142 | 6,193 | ~1,770 |
| **合计** | **521** | **26,229** | **~7,494** |

¹ 使用 ~3.5 chars/token（中英混合文本）。实际 tokenizer 结果可能偏差 ±20%。

**对比参考**: GenericAgent 的 L1 硬约束是 ≤30 行。Kagura 当前注入量是其 17 倍。

---

## 2. 频率分层

### L1 — 始终注入（安全关键 + 身份）

每次会话必须存在，移除会导致行为退化或安全风险。

| 来源 | 部分 | 行 | 字符 | tokens |
|------|------|---|------|--------|
| SOUL.md | 全文 | 55 | 3,811 | ~1,089 |
| IDENTITY.md | 全文 | 8 | 336 | ~96 |
| USER.md | 全文 | 13 | 366 | ~105 |
| AGENTS.md | Red Lines | 7 | 316 | ~90 |
| AGENTS.md | 隐私保护 | 11 | 977 | ~279 |
| AGENTS.md | 验证纪律 | 17 | 1,853 | ~530 |
| AGENTS.md | 数据纪律 | 7 | 584 | ~167 |
| AGENTS.md | Session Startup | 10 | 332 | ~95 |
| AGENTS.md | Memory | 33 | 1,948 | ~557 |
| **L1 小计** | | **161** | **10,523** | **~3,007** |

### L2 — 上下文触发（检测到匹配场景才注入）

只在特定场景下有用。如果 OpenClaw 支持条件注入，这些应该按触发条件加载。

| 来源 | 部分 | 触发条件 | 行 | 字符 | tokens |
|------|------|---------|---|------|--------|
| AGENTS.md | Group Chats | 群聊 session | 46 | 1,822 | ~521 |
| AGENTS.md | Heartbeats | heartbeat poll | 49 | 1,945 | ~556 |
| AGENTS.md | Subagent 代码规则 | 需要 spawn subagent | 22 | 1,035 | ~296 |
| AGENTS.md | Subagent 任务分配 | 需要 spawn subagent | 8 | 596 | ~170 |
| AGENTS.md | 打工循环 | work loop 场景 | 7 | 406 | ~116 |
| AGENTS.md | 讨好模式防范 | 审计/汇报场景 | 13 | 649 | ~185 |
| AGENTS.md | 自己的工具必须用 | FlowForge 相关 | 7 | 468 | ~134 |
| AGENTS.md | DNA Self-Governance | DNA 修改场景 | 14 | 1,047 | ~299 |
| AGENTS.md | External vs Internal | 对外操作 | 13 | 253 | ~72 |
| AGENTS.md | Tools | 工具使用 | 11 | 612 | ~175 |
| **L2 小计** | | | **190** | **8,833** | **~2,524** |

### L3 — 按需加载（reference data，用到时 `read` 即可）

纯查阅型数据，不影响行为模式，session 中需要时读文件即可。

| 来源 | 部分 | 行 | 字符 | tokens |
|------|------|---|------|--------|
| TOOLS.md | 本地生图 | 23 | 1,187 | ~339 |
| TOOLS.md | 打工 Repo 本地测试环境 | 30 | 1,739 | ~497 |
| TOOLS.md | Repos | 10 | 406 | ~116 |
| TOOLS.md | 飞书发图 | 6 | 453 | ~129 |
| TOOLS.md | VM1 | 7 | 398 | ~114 |
| TOOLS.md | Luna 远程管理 | 6 | 322 | ~92 |
| TOOLS.md | Discord | 1 | ~50 | ~14 |
| TOOLS.md | Whisper | 2 | ~100 | ~29 |
| TOOLS.md | Template examples | 20 | ~486 | ~139 |
| TOOLS.md | Header/boilerplate | ~37 | ~1,052 | ~301 |
| **L3 小计** | | **~142** | **~6,193** | **~1,770** |

### 分层汇总

| 层级 | 行 | 字符 | tokens | 占比 |
|------|---|------|--------|------|
| L1 (始终注入) | 161 | 10,523 | ~3,007 | 40.1% |
| L2 (条件触发) | 190 | 8,833 | ~2,524 | 33.7% |
| L3 (按需读取) | ~170 | ~6,873 | ~1,963 | 26.2% |
| **总计** | **521** | **26,229** | **~7,494** | 100% |

**核心发现**: 当前注入量中只有 40% 是每次必需的。60% 的内容在大多数 session 中是浪费。

---

## 3. 优化机会

### 3.1 死重清理（立刻可做，无需 OpenClaw 改动）

| 目标 | 动作 | 节省 | 难度 |
|------|------|------|------|
| TOOLS.md template examples | 删除 Cameras/SSH/TTS 示例块（从未使用） | ~486 chars / ~139 tokens | 🟢 trivial |
| TOOLS.md header boilerplate | 压缩 "What Goes Here" / "Why Separate?" 说明段落 | ~400 chars / ~114 tokens | 🟢 trivial |

**立即可节省: ~253 tokens**

### 3.2 内容压缩（可做，需谨慎编辑）

| 目标 | 动作 | 节省 | 难度 |
|------|------|------|------|
| AGENTS.md 验证纪律 | 8 条子规则有重叠，合并同类项 | ~200 tokens (估) | 🟡 medium |
| AGENTS.md Memory 部分 | 33 行偏冗长，可压缩到 ~20 行 | ~200 tokens (估) | 🟡 medium |
| AGENTS.md Heartbeats | 49 行含大量示例，可压缩到 ~25 行 | ~280 tokens (估) | 🟡 medium |
| AGENTS.md Group Chats | 46 行含重复的 "respond when/stay silent" 示例 | ~260 tokens (估) | 🟡 medium |

**压缩可节省: ~940 tokens（估）**

### 3.3 内容迁移到 L3（可做，TOOLS.md 整段移到独立文件）

| 目标 | 动作 | 节省 | 难度 |
|------|------|------|------|
| TOOLS.md 整体 | 全文移出 workspace injection，改为按需 `read TOOLS.md` | ~1,770 tokens | 🟡 medium² |

² TOOLS.md 的内容 100% 是 L3 参考数据。但当前 OpenClaw 机制是 workspace files 全量注入，无法单独排除某个文件。如果能在 OpenClaw 配置中指定哪些文件注入、哪些不注入，这是最大的单项收益。

### 3.4 条件注入（需要 OpenClaw feature work）

| 目标 | 触发条件 | 节省（非触发时） | 难度 |
|------|---------|-----------------|------|
| Group Chats 段 | `channel.type == group` | ~521 tokens | 🔴 需 OpenClaw |
| Heartbeats 段 | `trigger == heartbeat` | ~556 tokens | 🔴 需 OpenClaw |
| Subagent 段×2 | `spawning_subagent == true` | ~466 tokens | 🔴 需 OpenClaw |
| 打工循环 | `workflow == workloop` | ~116 tokens | 🔴 需 OpenClaw |

**条件注入理想节省: ~1,659 tokens（典型非群聊非心跳 session）**

---

## 4. 推荐行动（按 impact/effort 排序）

### Tier A — 今天就能做 ✅

1. **删除 TOOLS.md template examples**（Cameras/SSH/TTS 示例）
   - Impact: ~139 tokens
   - Effort: 1 分钟
   - Risk: 零（从未被使用）

2. **压缩 TOOLS.md header**（删 "What Goes Here" / "Why Separate?" / "Examples" 段落）
   - Impact: ~114 tokens  
   - Effort: 2 分钟
   - Risk: 零

### Tier B — 本周可做 🟡

3. **压缩 AGENTS.md 冗长段落**（Memory, Heartbeats, Group Chats）
   - Impact: ~740 tokens
   - Effort: 30 分钟（需逐段审查，确保语义不丢失）
   - Risk: 低（压缩不等于删除，核心规则保留）

4. **合并 AGENTS.md 验证纪律子规则**
   - Impact: ~200 tokens
   - Effort: 15 分钟
   - Risk: 低（合并重叠项，不删规则）

### Tier C — 需 OpenClaw 支持 🔴

5. **Workspace files 选择性注入**（配置哪些文件自动注入，哪些不注入）
   - Impact: ~1,770 tokens（排除 TOOLS.md）
   - Effort: OpenClaw feature request
   - 这是单项 ROI 最高的改动

6. **条件段注入**（根据 session 上下文只加载相关段落）
   - Impact: ~1,659 tokens（典型 session）
   - Effort: 需要 OpenClaw 支持 context-aware injection
   - 这是终极方案，但复杂度最高

### Tier D — 长期方向 🔵

7. **L1 硬约束机制**
   - 参照 GenericAgent 的 ≤30 行 L1 约束
   - 需要先建立"哪些行为退化了"的监测手段
   - 是架构目标，不是立即可做的事

---

## 5. 绝对不能动的内容（L1 红线）

以下内容必须始终注入，无论任何优化方案：

| 内容 | 原因 | tokens |
|------|------|--------|
| SOUL.md 全文 | 人格和行为基线，缺失 = 变成通用 chatbot | ~1,089 |
| IDENTITY.md 全文 | 身份锚定（名字、GitHub 等） | ~96 |
| USER.md 全文 | 知道在跟谁说话 | ~105 |
| AGENTS.md: Red Lines | 安全底线 | ~90 |
| AGENTS.md: 隐私保护 | 隐私安全（4 次事故后升级的硬规则） | ~279 |
| AGENTS.md: 验证纪律 | 最高频失败模式防护（18 次重复后升级） | ~530 |
| AGENTS.md: 数据纪律 | 防止编造数据 | ~167 |
| **L1 红线合计** | | **~2,356** |

另外 Session Startup (~95 tokens) 和 Memory (~557 tokens) 虽然也属于 L1，但如果极端压缩，这两段可以缩减（不能删除，但可以更精简）。

---

## 6. 现实约束

**OpenClaw 当前机制**: Workspace files（AGENTS.md, SOUL.md, IDENTITY.md, USER.md, TOOLS.md）在 session 启动时全量注入到 Project Context。没有：
- 单文件排除/包含配置
- 条件注入（根据 channel type / trigger type）
- 段落级选择性加载

**这意味着**: Tier A 和 Tier B（编辑文件内容）是当前唯一可行的优化路径。Tier C 和 D 需要向 OpenClaw 提 feature request。

**乐观估算**: 
- 仅做 Tier A+B → 节省 ~1,193 tokens（当前总量的 ~16%）
- 如果 OpenClaw 支持文件级排除 → 额外节省 ~1,770 tokens（排除 TOOLS.md）
- 如果 OpenClaw 支持条件段注入 → 典型 session 可降到 ~3,500 tokens（当前的 47%）

---

## 关联

- [[context-budget-constraint]] — 概念卡片，动机和设计选项
- [[genericagent]] — L1 ≤30 行硬约束的参考
- 后续: 实施 Tier A → 更新 baseline → 追踪 Tier B 效果
