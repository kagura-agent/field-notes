---
title: "Codex ON_USE AuthPolicy: 发现-按需授权模式"
created: 2026-04-11
source: "codex-rs source code (marketplace.rs, discoverable.rs, tool_suggest.rs, v2.rs)"
modified: 2026-04-11
tags: [codex, security, authorization, agent-router, plugin-system]
---

# Codex ON_USE AuthPolicy: 发现-按需授权模式

## 核心机制

Codex marketplace 的每个 plugin 有三层策略：

| 层 | 枚举值 | 作用 |
|---|---|---|
| **InstallPolicy** | NOT_AVAILABLE / AVAILABLE / INSTALLED_BY_DEFAULT | 能不能装 |
| **AuthPolicy** | ON_INSTALL / ON_USE | 何时授权 |
| **Products** | Product[] (可选) | 产品分级（不同 Codex SKU 可见性不同） |

**ON_INSTALL**（默认）：安装时一次性授权所有能力。传统模式。

**ON_USE**：安装时不授权，agent 用到时才弹窗请求授权。这是关键创新。

## 实现路径（源码跟踪）

```
marketplace.json
  └─ policy.authentication: "ON_USE"
      │
      ├─ marketplace.rs: MarketplacePluginAuthPolicy::OnUse
      │   └─ resolve_marketplace_plugin() → ResolvedMarketplacePlugin { auth_policy }
      │
      ├─ manager.rs: install_resolved_plugin()
      │   └─ PluginInstallOutcome { auth_policy } → 返回给客户端
      │
      ├─ v2.rs: PluginInstallResponse { auth_policy, apps_needing_auth }
      │   └─ 客户端根据 auth_policy 决定是否立即弹 OAuth/授权流程
      │
      └─ discoverable.rs: list_tool_suggest_discoverable_plugins()
          └─ 未安装但在 allowlist 的 plugin → DiscoverablePluginInfo
              └─ tool_suggest.rs: agent 调用 tool_suggest 工具
                  └─ 弹 elicitation UI → 用户确认 → 安装 + 授权
```

## 发现-按需授权的完整闭环

1. **发现阶段**：`discoverable.rs` 维护一个 allowlist（github, notion, slack, gmail 等 8 个 curated plugin），未安装的 plugin 以 `DiscoverablePluginInfo` 形式暴露给 agent
2. **建议阶段**：agent 在对话中判断需要某个 plugin → 调用 `tool_suggest` 工具 → 构建 elicitation request → UI 弹窗
3. **确认阶段**：用户 Accept/Deny → Accept 则触发安装
4. **安装阶段**：`install_resolved_plugin()` 返回 `auth_policy` + `apps_needing_auth`
5. **授权阶段**：如果 `auth_policy == ON_USE`，客户端**不**立即弹 OAuth；等到 agent 实际调用该 plugin 的工具时才触发 OAuth 流程

## 反直觉发现

### 1. ON_USE 当前只是**元数据标记**，不是运行时拦截
源码中 `auth_policy` 在 `PluginInstallOutcome` 中作为字段传递给客户端，但 **core 层没有运行时拦截逻辑**。具体的"用时才授权"行为依赖客户端（Codex App/Desktop）的 UI 实现。这意味着 CLI 模式下（codex-tui）ON_USE 可能退化为 ON_INSTALL。

### 2. Discoverable ≠ ON_USE
可发现（discoverable）和按需授权（ON_USE）是两个独立维度：
- 可发现 = 未安装但在 tool_suggest allowlist（硬编码 8 个）
- ON_USE = 已安装但未授权的 OAuth 延迟

### 3. Product gating 还是 TODO
源码注释：`// TODO: Surface or enforce product gating at the Codex/plugin consumer boundary`。多产品线策略还没落地。

### 4. tool_suggest 目前只支持 install action
```rust
if args.action_type != DiscoverableToolAction::Install {
    return Err(FunctionCallError::RespondToModel(
        "tool suggestions currently support only action_type=\"install\"".to_string(),
    ));
}
```
未来可能扩展到 enable/configure/upgrade。

## 对 OpenClaw 的启示

### agent-as-router 场景的适配

OpenClaw 作为个人 agent 路由器，管理多个 channel（Discord, 飞书, WhatsApp），天然是 agent-as-router。引入 ON_USE 模式意味着：

1. **Skill 可以"存在但未激活"**：ClawHub 上的 skill 可以被索引但不加载到 context，agent 判断需要时才激活
2. **减少 context 污染**：当前所有 available_skills 的 description 都注入 system prompt，ON_USE 模式下可以只注入"可发现"的摘要，具体 SKILL.md 用时才读
3. **Plugin 权限按需**：连接新 channel 或 MCP server 时，不预先申请所有权限

### 具体可落地的改进

**Phase 1：Skill 懒加载**
- available_skills 分两级：always-loaded（核心 skill）和 discoverable（可发现但不加载）
- discoverable skill 只注入 name + one-line description
- agent 判断需要时调用 `activate_skill(name)` → 读 SKILL.md → 加入 context

**Phase 2：MCP Server 按需连接**
- 配置中声明可用的 MCP server 但默认不连接
- agent 判断需要时请求连接 → 用户确认 → 建立连接

### vs Claude Code 的 Permission 系统

| 维度 | Codex ON_USE | Claude Code Auto Mode | OpenClaw 当前 |
|---|---|---|---|
| 授权粒度 | Plugin 级 | 工具调用级 | 无（全信任或全拒绝） |
| 授权时机 | 首次使用 | 每次调用（LLM classifier） | 无 |
| 用户交互 | Elicitation UI | Terminal confirm | approval card |
| 可发现性 | tool_suggest 主动建议 | 无 | 无 |

Codex 的方案更适合 **plugin 生态**（粗粒度、一次性），Claude Code 的方案更适合 **危险操作**（细粒度、每次判断）。OpenClaw 可以两者结合：plugin/skill 用 ON_USE，具体操作用 approval。

## 关联

- [[claude-code-vs-codex-plugin-systems]] — 本卡片是其 "待验证" 项的深入
- [[claude-code-permissions]] — Claude Code 的 6 层 permission 对比
- [[codex-marketplace-mcp-apps]] — Codex marketplace 全景
- [[cyberclaw]] — CyberClaw 的安全模型（另一个对比角度）
