---
title: "Code Review 教训"
created: 2026-03-26
---
## 安全/健壮性不是 afterthought
提交前检查：
- 有没有绕过已有的权限/隔离模式？
- binary 数据有没有经过 text 编码（会损坏）？
- 输入有没有 size 限制？
- 文件名/路径有没有转义？
- 错误响应有没有泄露内部信息？

## Workaround 债务
"我知道有问题但先这样" → review 一定会被打回。花在 workaround 上的时间 + 被打回重做的时间 > 一次做对的时间。

## 复用已有模式
提交前 grep 一下同类功能是怎么做的。项目里已有正确的安全模式时，不要造新的绕过它。

## 绕路 vs 直达
修 bug 先问"调用层能不能直接解决"，再考虑底层 workaround。
例：ThreadPoolExecutor workaround vs 直接用 async API，拼路径 vs sys.executable。

## PR 格式
Summary → Related Issue → Changes → Testing → Checklist

## Bot Review 也是 Review
CodeRabbit、cubic-dev 等 bot 的 review 不是噪音——它们经常指出真实的边界条件 bug（空数组、Error 序列化、日志重复）。这些问题不修，真人 reviewer 也会打回来。

**规则：** PR 提交后，bot review 出来要看。有效建议当场修，不要等真人 review 再补。GitHub Patrol 巡检时 bot review 和真人 review 同等对待。

---
来源：[[acontext]] PR #506 review, [[hindsight]] PR #678 复盘, [[hermes-agent]] PR #2715 复盘, 2026-04-23 Luna 指出 bot review 被忽视
