# Multi-Tier QA Strategy

> 来源: [[dora-rs]] scripts/qa/ (2026-04-22 深读)

## 核心思路

分层测试，越往上越慢、越全面，日常开发只跑快的：

| Tier | 时间 | 用途 | 内容 |
|------|------|------|------|
| --fast | ~1 min | pre-commit | fmt, clippy, audit, unwrap budget, typos |
| --full | ~5-10 min | pre-push | fast + tests + coverage |
| --deep | ~15 min | Tier 1 gate | full + mutation testing (diff only) + semver check |
| --nightly | ~3-4 hrs | CI nightly | deep + proptest@1000 + miri + 18 integration jobs |
| --mutation-audit | ~10-18 hrs | 审计 | 全 repo cargo-mutants, 6 关键 crate, 1679+ mutants |

## 关键设计决策

1. **本地 = CI**: 同一个脚本 `qa/all.sh` 在本地和 CI 跑，green local → green CI
2. **平台感知**: nightly jobs 按 OS 分派（macOS/Linux/Windows 各跑子集）
3. **进程安全**: 不用 `pkill` 杀全局进程，用 unique temp dir 路径匹配自己的进程
4. **工具缺失降级**: `timeout` 不存在就 warn + 无限运行，不 fail
5. **Unwrap Budget**: 用脚本追踪非测试代码中 `.unwrap()` 数量，有预算上限

## Adversarial Review Prompt

专门为 AI-authored PR 设计的 review checklist:
- Tautological tests（测试逻辑 = 实现逻辑）
- Unreachable defensive code（不可能触发的错误路径）
- Invariant violations（构造出违反自身类型不变量的值）
- Silent error swallowing（.ok(), let _ = ...）
- New unwrap in non-test code
- Concurrent bugs（锁顺序、共享状态）
- Breaking API changes not flagged
- Scope creep
- Missing tests for new branches
- Poorly-scoped mocks

## 对我们的启发

1. **OpenClaw 打工可以借鉴 adversarial prompt**: 提 PR 前自跑一次 adversarial review
2. **unwrap budget 思路**: 给 codebase 设质量指标预算，每次 PR 不能超标
3. **qa/all.sh 统一入口**: 比散落的 npm scripts 更一致
4. **mutation testing on diff**: 只对改动的代码跑 mutation，平衡速度和质量

Links: [[dora-rs]], [[coding-guidelines-for-prs]], [[agent-security]]
