# 打工目标公司

> 从 MEMORY.md 迁移,2026-04-08

## 选择框架
- 品牌×活跃度×领域深度。NVIDIA/字节品牌价值 > 小项目高 merge rate
- 核心原则:围绕 self-evolving agent 方向选公司,每个 PR 积累领域深度
- **选题流程(2026-04-02 Luna directive)**:主力/辅助有 issue → 做;没有 → 去 GitHub 找新的对齐 repo(trending/搜索),不碰不对齐的 repo,不管多好做

## 分类(2026-03-26 更新)
- **主力**: NemoClaw (NVIDIA), OpenClaw (TypeScript), Hermes (NousResearch, Python)
- **辅助**: deer-flow (字节, 44k⭐), claude-hud
- **观察**: Acontext (memodb-io), MemOS (MemTensor, 8.2k⭐, skill generation), blockcell, OpenCLI (8.6k⭐, YAML adapter), DeepTutor (HKUDS, 14.7k⭐, agent-native 学习助手), qmd (tobi, 19.5k⭐, 本地知识库搜索), 🆕 obra/superpowers (143k⭐, agentic skills framework), 🆕 Archon (coleam00, 14k⭐, AI coding harness builder)
- **维护中**: NemoClaw, ClawX, gitclaw(有 PR 等 merge)
- **退出**: math-project (bot 刷 review), repo2skill, supermemory, hindsight (maintainer 要求停止), OpenKosmos (不活跃)
- **退出 tenshu** - 不对齐 self-evolving agent 方向,4 个 PR 已够

## 打工里程碑
- 3/25 首次完整走 FlowForge + ACP 打工
- 4/2 hindsight maintainer 要求停止提交（频率过高），退到观察状态
- 4/4 memex #43 manifest pre-filter 被 maintainer merge（"高质量功能增强，代码规范、测试充分、设计优雅"）
- 4/4 教训：openclaw #60610 修复方向错（改共享 helper 没查所有 caller）→ 打工必须走 FlowForge workloop
- 4/5 NemoClaw #1502 修复 #746 回归 bug（prek 路径问题），等 review

## 打工成果
- **权威数据源**: `gh search prs --author=kagura-agent`
- 需每次 review 时当场查询刷新,不沿用旧数据
- Stale PR: 详见每 2h 巡检 cron

### 观察列表（Trending 发现）
- **multica-ai/multica** 🆕 — managed agents platform（任务分配+进度追踪+skill 复合），5.9k⭐，103 issues，2026-04-10 活跃。对齐方向：agent infra / skill 生态
- **obra/superpowers** 🆕 — agentic skills framework & dev methodology，145k⭐，266 issues，2026-04-10 活跃。对齐方向：skill 生态 / agent 基础设施
- **rowboatlabs/rowboat** 🆕 — AI coworker with memory，11.7k⭐，77 issues，2026-04-10 活跃。对齐方向：memory / agent infra
