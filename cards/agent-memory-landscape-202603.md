# Agent Memory 领域动态 — 2026 年 3 月

## Letta 生态
- letta-code v0.21.x：从 CLI 工具转向可嵌入 agent runtime（WebSocket Listener）
- /doctor 命令审计 memory 结构，reflection snapshot，skill enable/disable
- 走向"agent 内核 + 可插拔 skill/subagent"微内核架构
- agent-file (.af, 1k⭐)：agent 可移植性标准；竞争者有 OAF v0.8.0 和 Oracle Agent Spec

## Hindsight 动态
- memory lifecycle 补齐：delete endpoint + retrieval frequency tracking + fact type 分类
- Agent Memory Benchmark (AMB)：首个产品团队自建评估框架，LongMemEval 91.4%
- 从个人 memory → 团队/组织级 shared memory
- 集成：Codex + Claude Code，shared memory for AI coding agents

## 新兴项目
| 项目 | ⭐ | 要点 |
|---|---|---|
| OpenViking (ByteDance) | 20k | filesystem paradigm，91% lower token cost |
| engram | 2k | Go+SQLite+MCP，agent-agnostic，LOCOMO 80% |
| openclaw-auto-dream | 490 | REM sleep memory consolidation for OpenClaw |
| memsearch (Zilliz) | 1k | Markdown-first，Milvus 团队 |
| git-context-controller | 37 | Git 操作映射到 memory management |

## Sleep-time Compute 产品化
- Letta 从论文(2504.13171)走向产品：sleep-time agents 架构指南
- openclaw-auto-dream：凌晨 4 点 dream cycle，replay→提取→关联→fade
- 核心范式：agent 不工作时做后台思考/整理

## Memory + Self-Evolution 重要论文
- **MemSkill (2602.02474)** — memory 操作变 learnable skill
- **MemRL (2601.03192)** — episodic memory 上做 RL，非参数化自进化
- **MemMA (2603.18718, Microsoft)** — 多 agent memory lifecycle + in-situ self-evolution
- **Evo-Memory (Google DeepMind)** — experience reuse vs conversational recall
- **ICLR 2026 MemAgents Workshop (4/27)** — agent memory 升级为一级研究方向

## 对我们的启发
- 已做对：markdown-as-memory、daily review + beliefs 管线、heartbeat 后台处理
- 可改进：memory decay/importance scoring、consolidation（合并）+ forgetting（清理）、probe QA 验证、fact type 区分

## 下一步
1. 深入 MemSkill 论文
2. 试用 engram
3. 研究 OpenViking filesystem paradigm
4. 跟进 ICLR 2026 MemAgents Workshop (4/27)
5. 评估 openclaw-auto-dream 的 dream cycle
6. 关注 Hindsight AMB
