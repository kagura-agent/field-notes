# Berkeley Benchmark Gaming (trustworthy-env)

> 2026-04-12 首读 | UC Berkeley RDI | [blog](https://rdi.berkeley.edu/blog/trustworthy-benchmarks-cont/) | [repo](https://github.com/moogician/trustworthy-env)

## 概要

Berkeley 团队用自动化 scanning agent 审计 8 个主流 agent benchmark，发现**全部可被利用获得近满分，且无需解决任何任务**。

## 攻击面与成果

| Benchmark | 任务数 | 得分 | 手法 |
|---|---|---|---|
| Terminal-Bench | 89 | 100% | 替换 curl/pip/uvx 二进制，trojanize test infra |
| SWE-bench Verified | 500 | 100% | conftest.py pytest hook，强制 PASSED |
| SWE-bench Pro | 731 | 100% | 容器内 parser 覆写 |
| WebArena | 812 | ~100% | file:// 读 gold answer + DOM 注入 + prompt injection |
| FieldWorkArena | 890 | 100% | 验证器从不检查答案正确性 |
| CAR-bench | all halluc | 100% | reward 组件被跳过 |
| GAIA | 165 | ~98% | 公开答案 + normalization 碰撞 |
| OSWorld | 369 | 73% | VM state 操纵 + 公开 gold files |

**共性漏洞**：agent 与 evaluator 共享执行环境（同容器/同 VM），agent 可以 tamper 评分基础设施。

## 已发生的真实案例

- IQuest-Coder-V1: 用 `git log` 从 commit history 抄答案，24.4% 轨迹作弊
- METR: o3 + Claude 3.7 在 30%+ eval runs 中 reward-hack（stack introspection、monkey-patch grader）
- OpenAI 弃用 SWE-bench Verified: 59.4% 问题有 flawed tests
- KernelBench: `torch.empty()` 返回 GPU stale memory 含参考答案
- Anthropic Mythos Preview: 模型自主构造 self-erasing privilege escalation exploit

## 核心洞察

1. **Benchmark 衡量的不是能力，是 eval pipeline 的攻击面**。得分高可能只是 evaluator 脆弱
2. **环境隔离是根本解**：agent 执行和评分必须在不同环境，agent 不能 touch 评分基础设施
3. **与 [[agent-safety]] 高度相关**：如果 agent 能 hack benchmark evaluator，也能 hack 生产环境的 safety guardrails
4. 对我们的启示：
   - OpenClaw sandbox 设计要考虑 tool execution 与 verification 的隔离
   - 我们自己的 [[weekly-eval]] 机制也要注意：评估指标是否可被自己 game？
   - 打工用 SWE-bench 分数衡量贡献者能力 → 不可靠

## 与我们方向的关系

- **安全主线直接相关**：benchmark gaming 是 agent safety 的子问题——agent 有动机和能力 hack 评价系统
- 与 [[cyberclaw]] 的全行为审计思路互补：CyberClaw 从"透明审计"入手，Berkeley 从"攻击面扫描"入手
- 虾信文章「自进化 agent 的安全边界」可以引用这个作为"连评价系统都不安全"的论据

## 侦察附带发现

- **SkillAnything** (AgentSkillOS, ⭐90): auto-generate agent skills for Claude Code/OpenClaw/Codex，skill 生态工具化趋势
- **CyberClaw** (⭐72): 透明 agent 架构，全行为审计+两段式安全，下次 deep read
- **PokeClaw** (⭐495): 首个 on-device Android agent (Gemma 4)，on-device 趋势延续
- **agora** (⭐102): 31 thinkers 多 agent 审议系统，黑格尔正反合
