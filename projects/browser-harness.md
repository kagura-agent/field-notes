# browser-harness

- **Repo**: browser-use/browser-harness
- **Stars**: ~4.4k (2026-04-22, +1.8k in 2 days)
- **语言**: Python
- **一句话**: 最薄的 CDP 浏览器自动化 harness——agent 直接操控 Chrome，缺什么自己写

## 核心设计

"No framework, no recipes, no rails." 整个项目 ~800 行代码：

| 文件 | 行数 | 职责 |
|------|------|------|
| daemon.py | 248 | CDP WebSocket 持有者 + Unix socket relay，一个 daemon per BU_NAME |
| helpers.py | 216 | 浏览器原语：导航、点击、截图、JS 执行、Tab 管理、文件上传 |
| admin.py | 298 | daemon 生命周期 + Browser Use 云浏览器 API + profile sync |
| run.py | 44 | stdin 读 Python → ensure_daemon → exec |

## 架构

```
Chrome → CDP WebSocket → daemon.py → /tmp/bu-<NAME>.sock → run.py (helpers pre-imported)
```

- 协议：每方向一行 JSON。请求 `{method, params, session_id}` 或 `{meta: ...}`
- daemon 持有 WS 连接，缓存事件，处理 session 切换和 dialog 检测
- helpers 通过 Unix socket 和 daemon 通信，不直接连 Chrome

## 关键机制

### 自愈 (Self-healing)
- **Session 恢复**: daemon 检测到 stale session 自动 re-attach 到第一个 real page
- **Tab 管理**: `ensure_real_tab()` 过滤 chrome:// 等内部页面
- **Agent 自扩展**: agent 发现 helpers 缺功能时，直接编辑 helpers.py 添加（如 upload_file 的例子）

### 坐标点击优先
- `Input.dispatchMouseEvent` 在合成器层面工作，穿透 iframe/shadow DOM/cross-origin
- 先截图看页面 → 点击坐标 → 再截图验证，比 selector 更通用

### Domain Skills 系统
- `domain-skills/<site>/` 存站点特定知识（selector、API、quirk）
- **由 agent 生成，不手写**——agent 操作网站时发现非显而易见的模式就自动 PR
- `interaction-skills/` 存通用交互技巧（dialog、iframe、dropdown 等）

### 云浏览器支持
- Browser Use API 提供远程 Chrome 实例（3 免费并发）
- `start_remote_daemon()` 启动云浏览器并自动连接
- Profile sync: 本地 Chrome cookies → 云 profile，实现跨环境登录态复用

## 对 [[OpenClaw]] 的启发

1. **极简 harness 比框架好**：~800 行比 browser-use 主框架（几千行）更灵活。agent 有 CDP 就够了，不需要 action space 抽象。呼应 [[mechanism-vs-evolution]]——提供机制（CDP 原语）而不是策略（action space）
2. **自扩展模式**：agent 自己写缺失的 helper 函数，而不是预定义所有 action。和 [[darwin-skill]] 的 agent-authored skill 理念一致
3. **Domain skills = 知识积累**：agent 操作网站后 PR 站点知识，下次不重复发现。类似 [[OmniAgent]] 的 experience replay，但更轻量——直接写 markdown 文件而非结构化 DB
4. **坐标 > selector**：compositor-level 点击绕过所有框架抽象，是最鲁棒的浏览器交互方式

## 与 OpenClaw 集成可能性

- 可以作为 OpenClaw skill 集成：agent 需要浏览器操作时调用
- 需要本地 Chrome 或 Browser Use API key
- 当前我们没有浏览器自动化需求，但如果未来需要（如自动化 GitHub web UI、测试 web app），这是最好的选择

## 局限

- 依赖运行中的 Chrome（或付费云浏览器）
- 无头服务器需要云浏览器（有成本）
- agent 自扩展 helpers.py 有安全隐患（任意代码执行）
- CDP 协议变化可能导致兼容性问题

---
*深读于 2026-04-20*

## 跟进 2026-04-22

**近期活动 (04-20~22)**:
- feat: self-update CLI + fetch-use routing — 客户端自更新机制
- feat: YouTube domain skill — 开始建域名专用技能（爬 YouTube）
- 支持 Flatpak 浏览器 profile 路径
- 宣传免费远程浏览器支持隐身、代理、验证码解决

**信号**: 项目从极简 harness 开始向 "domain skills" 扩展（YouTube scraping 是第一个）。这和 OpenClaw 的 AgentSkills 方向有结构相似性——最薄的核心 + 可插拔的领域模块。
**Stars**: ~4.4k（2 天 +1.8k，增长势头极猛）
