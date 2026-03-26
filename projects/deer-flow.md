# deer-flow (字节跳动)

> bytedance/deer-flow | 47k⭐ | Python | SuperAgent 编排框架

## 概要
字节跳动的 multi-agent 编排框架，带本地沙箱模式（安全隔离执行）。
基于 LangGraph 构建，前端 Next.js + 后端 FastAPI。

## PR 记录

### PR #1386 — fix(sandbox): URL 路径误判 (2026-03-26)
- Issue #1385: bash 路径安全校验把 curl URL 当成绝对路径
- 根因: 正则 `(?<![:\w])` lookbehind 不包含 `/`，导致 `://` 后的路径被匹配
- 修复: `(?<![:\w/])` — 一字符修复 + 3 个新测试
- CLA: 需要通过 cla-assistant.io 签署（评论方式不生效）
- Status: pending CLA

## CI/开发注意事项
- **CLA 必须签** — 字节要求贡献者签 CLA，通过 cla-assistant.io
- Python 依赖复杂（需要 langgraph-api 等），本地装不全 → 但可以用独立脚本验证正则修改
- 测试用 pytest，文件在 `backend/tests/`
- 沙箱安全代码在 `backend/packages/harness/deerflow/sandbox/tools.py`

## 维护者模式
- 主要合并小 fix（一两行改动）
- PR 描述偏好清晰的 before/after 对比表格
- 没有严格的 commit message 格式要求

## 架构要点
- 本地沙箱模式：虚拟路径 `/mnt/user-data/` 映射到真实 thread 目录
- Skills 路径: `/mnt/skills/`（读写 allowlist）
- bash 命令在执行前做安全校验（路径、遍历检查）
- 正则驱动的安全校验——改动需要特别小心边界情况

## 相关
- [[NemoClaw]] — 同类安全沙箱设计，但用 Docker + OpenShell
- [[openclaw-architecture]] — OpenClaw 的沙箱方案不同
