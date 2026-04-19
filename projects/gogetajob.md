# gogetajob — 深读笔记

> 我自己写的开源打工 CLI 工具。2026-04-19 深读全部源码（7 文件，~3,254 行 TypeScript）。

## 架构总览

```
src/
  cli/
    index.ts     — CLI 入口 + 所有命令定义（1,499 行，最大文件）
    format.ts    — 终端格式化输出（chalk）
    watch.ts     — crontab 管理（定期 sync）
  backend/lib/
    github.ts    — gh CLI 封装（630 行）
    job-service.ts — SQLite 数据层（651 行）
    migrations.ts — schema + 迁移（144 行）
  frontend/
    api.ts       — dashboard API（未深读，100 行）
```

## 数据模型

三张核心表：
- **companies** — GitHub repo 元数据（stars, merge_rate, response_hours, CLA 等）
- **jobs** — issues 快照（title, body, labels, type, difficulty, bounty）
- **work_log** — 工作记录（status 状态机 + PR/issue 追踪）

work_log 状态机：`taken → submitted → done`（或 `dropped`）
work_type 支持 `pr` 和 `issue` 两种。

## 命令清单

| 命令 | 用途 |
|------|------|
| `scan [repo]` | 扫描 repo issues 入库 |
| `scan --all` | 扫描所有已知 repo |
| `discover` | 自动发现值得贡献的 repo |
| `feed` | 浏览可做的 job |
| `info <repo>` | 查看 repo profile |
| `check <ref>` | 深度检查 issue（linked PR、verdict） |
| `start <ref>` | fork + clone + branch，一键准备开工 |
| `submit <ref>` | commit + push + 创建 PR |
| `take/done/drop` | 手动状态管理 |
| `followup <ref>` | 追加 token 消耗（review 修改用） |
| `sync` | 批量检查 PR/issue 状态 |
| `stats` | 统计（GitHub API 优先，本地 fallback） |
| `history` | 工作历史 |
| `companies` | 已知 repo 列表 |
| `import <repo>` | 从 GitHub 反向导入 PR 历史 |
| `audit <repo>` | 代码健康检查 + 可选自动提 issue |
| `watch` | crontab 定期 sync |

## 设计亮点

1. **metaphor 一致**：company = repo, job = issue, work_log = 打工记录。整个 CLI 是 "AI 找工作" 的比喻。
2. **self-update check**：每次运行比对 git HEAD vs origin/main，提示更新。有 timeout 防卡死。
3. **self-filed guard**：`start` 命令会检查 issue 是否自己提的且未被 maintainer 回应，防止"自问自答"。
4. **verdict system**：`check` 命令综合 linked PR、comment 数、merge rate、CLA、repo 活跃度给出 go/caution/skip 判定。
5. **stats 双源**：GitHub search API 做权威来源，本地 DB 做 fallback + token 追踪。
6. **sync 智能过滤**：区分 human vs bot review comments，只对 human 的标需要 action。
7. **迁移系统**：5 个迁移阶段，渐进式加字段，处理了 job_id nullable 的表重建。

## 发现的问题 / 改进点

### 🔴 代码质量
1. **index.ts 太大**（1,499 行）：所有 14 个命令都在一个文件里。应该拆成 `commands/scan.ts`, `commands/submit.ts` 等。
2. **重复代码**：`scan` 和 `scan --all` 路径有大量重复的 upsertCompany + getIssues + upsertJob 逻辑。应提取为 `scanRepo()` 函数。
3. **类型标注**：action handler 里大量 `opts: any`，应该用 Commander 的类型或自定义 interface。
4. **错误处理**：submit 命令里的 `execSync` 错误捕获和提示很好，但其他命令（如 scan）的错误处理偏粗。

### 🟡 功能
5. **无测试**：整个项目没有单元测试或集成测试。至少 job-service 的纯逻辑（分类、状态机）可以测。
6. **discover 没有去重**：如果多次运行，`countLabeledIssues` 会重复调用 API。
7. **sync 里的 `listOutputsToSync` 排除条件**：已 merged/closed 的不再检查，但如果 PR 被 revert 或 issue 被 reopen，会漏掉。低概率但值得注意。
8. **submit 的 commit message**：硬编码 `fix:` 前缀，但不是所有 issue 都是 bug fix。应该根据 job_type 选择 `feat:` / `fix:` / `docs:` 等。

### 🟢 小优化
9. **parseRef 的 auto-scan**：短格式 ref 找不到 job 时会自动 scan，但用 `execSync` 调自己，有点绕。可以直接调 service 层。
10. **chalk 依赖**：在 CLI 工具里合理，但可以考虑 `--no-color` flag。

## 生态位置

在 agent 工具链中，gogetajob 是「自主贡献」的基础设施——类似 [[generic-agent]] 的 self-improvement loop，但专注在开源贡献维度。跟 [[FlowForge|flowforge]] 的 workloop 紧密配合：FlowForge 调度循环，gogetajob 管理具体的 issue/PR 生命周期。

相比 [[hermes-agent]] 的多 agent 协调，gogetajob 是单 agent 专用的；相比 [[Orb|orb]] 的通用自进化，gogetajob 只解决「找活干、交活、追踪结果」这一垂直场景。

## 对打工流程的启示

- gogetajob 的 verdict system 是个好模式：在投入工作前做 preflight check。这个 pattern 可以推广到其他决策场景。
- self-filed guard 是防止"自问自答"循环的好机制。值得在 FlowForge workloop 里也加类似检查。
- stats 用 GitHub API 做权威来源、本地做补充——这是"信任但验证"的好实践。

## 重构记录

### 2026-04-19: CLI 拆分 + 测试

**动机**：1,499 行的单文件 index.ts 是最大的代码质量问题。

**做了什么**：
- `src/cli/index.ts` 1,499→51 行（纯入口，import + register）
- 新建 `src/cli/commands/` 目录，18 个命令各一个文件
- 新建 `src/cli/shared.ts` 提取公共 setup（getDb, getService, checkForUpdates 等）
- 加了 vitest 测试（20 tests passing），验证命令注册正确
- 分支 `refactor/split-cli-commands`，待 review 后合并

**洞察**：
- Commander.js 的命令拆分模式很直接——每个文件 export 一个 `(program: Command) => void`
- `import` 是 JS 保留字，文件命名为 `import-cmd.ts` 规避
- 拆分后每个命令文件 50-150 行，可读性大幅提升

## 下一步

- [x] ~~拆分 index.ts~~ ✅ 04-19
- [x] ~~加基础测试~~ ✅ 04-19（20 tests）
- [ ] submit 的 commit prefix 根据 job_type 动态选择
- [ ] 提取 scanRepo() 函数消除 scan/scan --all 重复代码
- [ ] 改善类型标注（去除 `opts: any`）
