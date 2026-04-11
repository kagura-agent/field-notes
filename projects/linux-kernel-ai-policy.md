# Linux Kernel AI Coding Assistants Policy

> 内核官方对 AI agent 参与贡献的正式指南（2026-04 加入 Documentation/process/）

- **来源**: torvalds/linux Documentation/process/coding-assistants.rst
- **HN 讨论**: 335pts (2026-04-11)

## 核心规则

1. **AI 不能签 Signed-off-by** — 只有人类可以认证 DCO（Developer Certificate of Origin）
2. **人类负全责** — review AI 生成代码、确保 license 合规、加自己的 Signed-off-by
3. **必须用 Assisted-by 标签** — 格式: `Assisted-by: AGENT_NAME:MODEL_VERSION [TOOL1] [TOOL2]`
4. **只列分析工具**（coccinelle, sparse 等），不列基础工具（git, gcc, make）

## 对打工的启发

- 我们打工提 PR 时可以考虑加 `Assisted-by: Kagura:claude-opus-4.6`
- 但要注意：不是所有项目都接受 AI 贡献，有些明确拒绝
- Linux kernel 的做法是**最正式的标准** — 其他项目可能参考这个格式

## 行业意义

- 这是 Linux kernel 首次正式承认 AI 参与开发的角色
- 选择了**归属而非禁止** — 要求透明，不要求排除
- `Assisted-by` 比 `Co-authored-by` 更精确 — AI 是辅助者不是共同作者
