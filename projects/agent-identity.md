# Agent Identity — 凭证自管理

> 2026-04-23 启动 | Luna 提议
> 关联：[[agent-security]], GTM (npm publish 被 2FA 卡住触发)

## 背景
每次 npm publish / 新服务注册都要 Luna 操作密码和 2FA。Luna 提出：agent 应该自己管理凭证，加密存储，不依赖人类。

## 目标
- CLI 友好的密码/凭证管理
- 加密存储（GPG/age）
- Git 私有 repo 备份
- Agent 可自主完成日常 auth

## Repo
- GitHub: kagura-agent/agent-identity (private)
- Discord: #agent-identity (1496666666099019857)

## 待调研工具
- **pass** — Unix 哲学，GPG + git，最轻量
- **gopass** — pass 增强版，team 功能，age 支持
- **sops** — Mozilla 出品，YAML/JSON 加密，适合 config
- **Bitwarden CLI** — 功能全但需要 server
- **age** — 现代加密，比 GPG 简单，但太底层

## 评估维度
1. Agent 可操作性（无 GUI，纯 CLI）
2. 加密强度
3. Git 友好度
4. 安装复杂度
5. 社区活跃度

## 进展

### Phase 1: 工具选型 ✅ (2026-04-23)
- 评估 pass / gopass / sops / Bitwarden CLI / age
- 结论：**pass** (GPG + git) 管日常凭证 + **sops** (age) 管配置文件加密
- 详见 PR #5

### Phase 2: 部署 ✅ (2026-04-23)
- pass 安装，GPG key 生成（无密码，agent 专用）
- 35 个 secret 迁入（openclaw/, hermes/, github/, ssh/）
- Issue #4 closed

### Phase 3: 加固 ✅ (2026-04-28)
- Age key 备份到 pass
- 旧 GPG key 清理（2 个移除，剩 2 个活跃）
- 轮换策略文档化（policy/rotation.md, PR #7）
- password-store 私有 git remote 备份上线
- Issue #6 closed

### Deferred
- **openclaw.json sops 加密** — 需要 OpenClaw 上游支持 sops config 读取，当前无法本地解决

## 状态
✅ 核心功能完成，进入维护期
