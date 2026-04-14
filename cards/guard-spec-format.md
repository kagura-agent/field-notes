---
title: Guard Spec Format
created: 2026-04-14
source: RivonClaw 规则三分法 applied to Kagura's AGENTS.md red lines
related: tool-execution-policy-enforcement, beliefs-upgrade-quality-gate, rivonclaw, agent-safety
status: prototype
---

## 概念

将 AGENTS.md 的红线规则形式化为结构化 guard spec，从"系统提示里的文字约束"升级为"可由 hook 拦截的机器可读条件"。

基于 [[rivonclaw]] 的三分法：
1. **policy-fragment** — 软约束，注入 system prompt（行为引导，不可程序化拦截）
2. **guard** — 硬约束，拦截 tool call（JSON 条件匹配 → block/confirm/modify）
3. **action-bundle** — 新能力，物化为 SKILL.md

## AGENTS.md 红线分类

| # | 红线规则 | 分类 | 可执行性 | 理由 |
|---|---------|------|----------|------|
| 1 | Don't exfiltrate private data | **guard** | 🟡 部分 | 可检查 exec 中的外部 URL/curl/scp，但语义泄露难拦截 |
| 2 | Don't run destructive commands without asking | **guard** | 🟢 今日可实现 | 拦截 exec 中的 rm/rmdir/dd/mkfs 等 |
| 3 | `trash` > `rm` | **guard** | 🟢 今日可实现 | 拦截 exec 中的 `rm` 命令，建议替换为 `trash` |
| 4 | Self repos → branch + PR | **guard** | 🟢 今日可实现 | 拦截 `git push` 到 main/master |
| 5 | 隐私保护 — commit 前 grep | **guard** | 🟡 部分 | 可在 git push 前 grep 敏感词，但需要 pre-push 逻辑 |
| 6 | 隐私保护 — .gitignore first | **guard** | 🟡 部分 | 可检查 git init/commit 时 .gitignore 是否存在 |
| 7 | 验证纪律 | **policy** | 🔴 行为层面 | 无法程序化判断"是否验证过再声称" |
| 8 | 数据纪律 | **policy** | 🔴 行为层面 | 无法程序化判断"数据是否基于实际查询" |
| 9 | 讨好模式防范 | **policy** | 🔴 行为层面 | 纯心理/动机层面，不可拦截 |
| 10 | Subagent 代码规则 — 用 Claude Code | **policy** | 🟡 部分 | 可检测 subagent 是否调了 claude，但判断"该用没用"很难 |
| 11 | Subagent 代码规则 — 必须测试 | **policy** | 🟡 部分 | 可检查 git push 前是否有 test 命令执行，但覆盖率无法判断 |

**统计**: 4 条可做 guard（今日可实现），3 条部分可做，4 条纯 policy

## Guard Spec Schema

```yaml
# guard-spec v0.1 (prototype)
guards:
  - id: string              # 唯一标识，kebab-case
    name: string            # 人类可读名称
    description: string     # 一句话说明为什么存在这条 guard
    severity: critical | warning  # critical = block, warning = confirm
    conditions:             # ALL conditions must match (AND logic)
      - tool: string        # 工具名匹配: "exec", "write", "edit", "*"
        match:              # 至少一个匹配条件 (OR within match)
          command: regex    # exec 命令内容正则
          path: glob        # write/edit/read 路径 glob
          content: regex    # 写入内容正则
          params: jsonpath  # 任意参数 JSONPath
    action: block | confirm | modify
    message: string         # 触发时显示给 agent/user 的消息
    modify_to: string       # action=modify 时的替换建议
    exceptions:             # 白名单（匹配则跳过此 guard）
      - path: glob
      - command: regex
    source: string          # 对应的 AGENTS.md 规则引用
    enforceable: boolean    # 当前 OpenClaw 能否通过 hook 实现
```

## 具体 Guard Specs

### Guard 1: trash-over-rm

```yaml
- id: trash-over-rm
  name: "Use trash instead of rm"
  description: "Recoverable deletion beats permanent deletion. trash > rm."
  severity: warning
  conditions:
    - tool: exec
      match:
        command: "\\brm\\s+(-[rRfFiI]*\\s+)*[^|]"
  action: modify
  message: "🗑️ Use `trash` instead of `rm` for recoverable deletion."
  modify_to: "trash"
  exceptions:
    - command: "rm -rf node_modules"  # 重建成本 = 0
    - command: "rm .*\\.tmp$"          # 临时文件
  source: "AGENTS.md → Red Lines → trash > rm"
  enforceable: true
```

**执行力**: 🟢 今日可实现。`before_tool_call` hook 检查 exec 工具的 command 参数，regex 匹配 `rm` 命令。action=modify 建议替换为 `trash`，但不硬拦（severity=warning → confirm）。

### Guard 2: no-push-to-main

```yaml
- id: no-push-to-main
  name: "Self repos must use branch + PR"
  description: "不直接推 main。开 branch → 写代码 → 提 PR → 验证 → 合并。"
  severity: critical
  conditions:
    - tool: exec
      match:
        command: "git\\s+push\\s+(origin\\s+)?(main|master)\\b"
  action: block
  message: "🚫 Direct push to main/master blocked. Use a feature branch and open a PR."
  exceptions:
    - command: "git push.*--tags"  # tag push is fine
  source: "AGENTS.md → Red Lines → 自己的 repo 也走 branch + PR"
  enforceable: true
```

**执行力**: 🟢 今日可实现。正则匹配 `git push origin main` 或 `git push master`。硬拦截（severity=critical → block），没有 confirm 选项。

### Guard 3: pii-in-public-commit

```yaml
- id: pii-in-public-commit
  name: "Grep for PII before public commit"
  description: "Public repo commit 前必须搜敏感词。4 次泄露历史。"
  severity: critical
  conditions:
    - tool: exec
      match:
        command: "git\\s+(push|commit)"
  action: confirm
  message: |
    ⚠️ About to git push/commit. Have you grepped for PII?
    Checklist: real names, emails, addresses, machine names, company names,
    .memexrc, tokens, credentials.
    Run: grep -rn '<sensitive_pattern>' . before continuing.
  exceptions:
    - path: "~/.openclaw/workspace/wiki/**"  # private wiki (not public)
    - path: "~/.openclaw/workspace/memory/**"
  source: "AGENTS.md → 隐私保护 → 发布前 grep"
  enforceable: true  # but needs path context to know if repo is public
```

**执行力**: 🟡 部分。hook 能拦截 git push/commit 命令，但判断 repo 是否 public 需要额外逻辑（查 git remote + GitHub API）。作为 prototype，先对所有非白名单 repo 触发 confirm。

### Guard 4: no-exfiltration

```yaml
- id: no-exfiltration
  name: "Block data exfiltration attempts"
  description: "Private data stays private. Block outbound data transfers to unknown endpoints."
  severity: critical
  conditions:
    - tool: exec
      match:
        command: "(curl|wget|scp|rsync|nc|netcat)\\s+.*(-d|--data|--upload|>)"
    - tool: web_fetch
      match:
        params: "$.url"  # any web_fetch could be exfil, log for review
  action: confirm
  message: "🔒 Outbound data transfer detected. Is this authorized? Destination: {matched_url}"
  exceptions:
    - command: "curl.*api\\.github\\.com"  # GitHub API is fine
    - command: "curl.*npmmirror\\.com"     # npm mirror
    - command: "curl.*wttr\\.in"           # weather
  source: "AGENTS.md → Red Lines → Don't exfiltrate private data"
  enforceable: true  # basic patterns; semantic exfil not catchable
```

**执行力**: 🟡 部分。能拦截明显的 curl/scp/rsync 外发命令。但无法拦截语义层面的泄露（比如把私人信息写进 public repo 的 README）。白名单需要维护。

### Guard 5: destructive-command-confirm

```yaml
- id: destructive-command-confirm
  name: "Confirm before destructive commands"
  description: "Don't run destructive commands without asking."
  severity: critical
  conditions:
    - tool: exec
      match:
        command: "(dd\\s+if=|mkfs|fdisk|parted|wipefs|\\bkill\\s+-9|systemctl\\s+(stop|disable)|docker\\s+system\\s+prune|DROP\\s+TABLE|DROP\\s+DATABASE|TRUNCATE)"
  action: confirm
  message: "💀 Destructive command detected. Are you sure? This may cause irreversible damage."
  exceptions: []
  source: "AGENTS.md → Red Lines → Don't run destructive commands without asking"
  enforceable: true
```

**执行力**: 🟢 今日可实现。纯正则匹配。OpenClaw 已有 approval system 做类似的事（elevated commands），这里是额外的 agent-level guard。

## 今日可实现 vs 远期愿景

### 今日可实现（OpenClaw `before_tool_call` hook）

| Guard | 机制 | 复杂度 |
|-------|------|--------|
| trash-over-rm | exec command regex | 低 |
| no-push-to-main | exec command regex | 低 |
| destructive-command-confirm | exec command regex | 低 |
| pii-in-public-commit | exec command regex + confirm | 中 |
| no-exfiltration (basic) | exec command regex + whitelist | 中 |

**实现路径**: 写一个 OpenClaw plugin，在 `before_tool_call` hook 中评估 guard spec 列表。
参考 [[tool-execution-policy-enforcement]] — hermes-agent 的 `pre_tool_call` 返回 `{"action":"block","message":"reason"}` 模式。

### 远期愿景（需要更多基础设施）

| 能力 | 缺什么 |
|------|--------|
| 语义泄露检测 | 需要 embedding 比对（"这段内容跟私人数据相似度多少"） |
| Public/private repo 自动判断 | 需要 git remote → GitHub API → visibility 查询 |
| "是否跑过测试" 检测 | 需要 session 级状态追踪（"push 前的命令历史里有没有 test"） |
| Policy compliance scoring | 需要 post-session 分析（像 [[beliefs-upgrade-quality-gate]] 的质量维度） |
| Guard 冲突检测 | 需要 guard-spec 之间的依赖/冲突分析 |

## Guard 与 Policy 的互补关系

Guard 拦截工具调用，Policy 塑造决策过程。两者不可互相替代：

```
决策过程（Policy 域）
  ↓
"我要 push 代码"
  ↓
工具调用（Guard 域）
  ↓
before_tool_call → guard evaluator → block/confirm/allow
  ↓
工具执行
```

**验证纪律**、**数据纪律**、**讨好模式防范** 永远是 policy——它们约束的是"决定做什么"，不是"怎么做"。Guard 能 catch 的是执行层面的红线违反，是最后一道安全网。

## 相关概念

- [[rivonclaw]] — 规则三分法的来源
- [[tool-execution-policy-enforcement]] — hook 拦截的技术参考
- [[beliefs-upgrade-quality-gate]] — 规则升级的质量门控
- [[agent-safety]] — 安全第二主线
- [[exp-017-guard-spec-prototype]] — 此格式的实验追踪
