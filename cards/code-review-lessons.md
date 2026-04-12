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

---
来源：[[acontext]] PR #506 review, [[hindsight]] PR #678 复盘, [[hermes-agent]] PR #2715 复盘
