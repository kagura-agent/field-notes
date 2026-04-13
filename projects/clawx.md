# ClawX — 田野笔记

## 项目概况
- **Repo**: AeroClawX/ClawX (Electron + React)
- **主维护者**: su8su (paisley)
- **技术栈**: Electron + React + TypeScript
- **本地测试**: `npm install --legacy-peer-deps && npm test`
  - 346 pass, 6 suite fail（pre-existing peer dep 问题，与代码无关）
- **CI**: E2E 跑三平台（ubuntu / windows / macos），fork PR 需 maintainer approve workflow 才能触发

## 贡献记录

### PR #733 — fix(menu): route Cmd+N to new chat session (Issue #720)
- **状态**: pending merge, CI 5/5 全绿 ✅
- **根因**: menu.ts 导航到 `/chat` 但路由不存在，Cmd+N 打开空白窗口
- **修复**: 新增 `new-chat` IPC 事件 + 修正路由
- **踩坑**: 首次提交忘了在 `preload/index.ts` 的 IPC allowlist 加 `new-chat` → E2E 全挂 → 第二次 commit 修复

### PR #820 — fix(gateway): adopt external gateway instead of killing it (Issue #818)
- **状态**: pending review (CI awaiting approval)
- **根因**: findExistingGatewayProcess() 先 kill 再 probe，systemd 管理的 gateway 被杀后自动重启 → 无限循环
- **修复**: 反转顺序 probe-then-kill；新增 Linux systemd stopSystemdGatewayService()（与 macOS launchctl 处理对称）
- **测试**: 5/5 gateway-supervisor tests pass，新增 2 个 test（adopt path + systemd stop）
- **踩坑**: npm install 在这个 2G+ Electron 项目上容易 OOM/ENOTEMPTY，需要 `rm -rf node_modules` 完全重装

## Workloop #19 选题失败 (2026-04-07)

### #664 和 #708 都指向 openclaw gateway
- #664: 研究后发现根因在 openclaw gateway，不是 ClawX 能修的
- #708: 同样根因在 openclaw gateway
- openclaw 有 4 个 open PR 且 0 merged，消化能力不足
- #392: 已有 3 个竞争 PR
- **关键发现**：ClawX 很多 issue 的根因在 openclaw gateway，不是 ClawX 层能解决的。选题时必须先判断根因层级
- **结论**：ClawX 当前可做的 issue 很少（多数需要 gateway 先修），需要扩展到其他 repo

## 关键教训

### Electron IPC 三件套
加新 IPC channel 时，**必须同时更新三处**：
1. **main 进程** — 发送 (`BrowserWindow.webContents.send`)
2. **renderer 进程** — 监听 (`window.electronAPI.onXxx`)
3. **preload/index.ts** — allowlist（`on` 和 `once` 两个列表都要检查）

遗漏 preload allowlist 的后果：IPC 消息被 preload bridge 静默拦截，renderer 收不到事件，功能不工作，E2E 全挂。

**排查方法**: 加新 IPC channel 时，`grep -r` preload 目录确认 allowlist 已更新。

### CI 注意事项
- Fork PR 提交后 CI 不自动跑，需要 maintainer approve workflow
- E2E 跑三平台，Windows 和 macOS 上的行为可能与 Linux 不同
- 本地 `npm test` 的 6 个 fail 是 peer dep 缺失导致的 pre-existing 问题，不影响 PR

### PR #848 — fix(exec): suppress Dock icon bounce for child processes on macOS (Issue #834)
- **状态**: pending review, CI 6/6 全绿 ✅
- **根因**: child_process.spawn/exec 继承 Electron GUI context，macOS 把子进程当前台应用显示 Dock 图标
- **修复**: 在 gateway fetch-preload 脚本加 macOS block，给所有 child_process 方法注入 LSUIElement=1 环境变量
- **实现方式**: 镜像已有 Windows windowsHide 补丁模式，+40 行
- **踩坑**: 
  - npm install 这个项目很容易 OOM（2G+ Electron），需 `rm -rf node_modules` 完全重装
  - PR #1084 base 不是 main 而是 dev，rebase 时要确认 target branch
  - `pnpm-lock.yaml` 被 lint-staged 自动创建但 main 上不存在，需移除
- **维护者模式**: 非常活跃（每天 merge），PR 描述需清晰（问题+根因+修复+测试），CI 必须全绿

## 观察
- ClawX 有完善的 Windows 兼容性补丁但 macOS 的被忽略——后续可扫描是否有其他 macOS 缺失的兼容处理
- preload 脚本是 template string 内嵌 JS，不受 TypeScript 类型检查
- E2E 跑三平台（ubuntu/windows/macos），fork PR 需 maintainer approve workflow
