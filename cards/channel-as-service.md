# Channel-as-Service Pattern

> Discord channel 作为微服务端点，接收自然语言请求，处理后返回结果。

## 概念

把 Discord channel 当成一个有状态的服务：
- **Skill 模式**：调用方自己跑代码，skill 只是菜谱
- **Channel-as-Service**：调用方发请求到 channel，channel 接单处理，结果回传

Channel 比 skill 多了**可见性**和**记忆**——所有请求和结果都在 Discord 里可见，channel 的上下文会积累领域经验。

## 实现（混合模式）

纯 session 层或纯 channel 层各有问题，混合模式最佳：

### Session 层（请求-响应）
```
sessions_send(sessionKey="agent:kagura:discord:channel:<target_channel_id>", message="自然语言请求", timeoutSeconds=180)
```
- 同步等回复，适合 cron/后台任务
- 需要配置 `tools.sessions.visibility: "all"`（默认 `tree` 不允许跨 channel）

### Channel 层（展示）
处理完后，用 `openclaw message send` 往 Discord channel 发结果展示：
```bash
openclaw message send --channel discord --account kagura \
  --target "channel:<target_channel_id>" \
  --message "🎨 完成：<描述>"
```

### 为什么需要混合
- `sessions_send` 不在 Discord 显示消息（只走 session 内部通信）
- `openclaw message send` 发的消息会被 bot 当 self-message 忽略（不触发处理）
- 混合：session 层做事，channel 层展示

## 已验证实例

### #kagura-canvas（画图工厂）
- Channel ID: `1497073534004891648`
- Session Key: `agent:kagura:discord:channel:1497073534004891648`
- 请求方发自然语言描述 → canvas 用 Flux/Gemini 生图 → 返回图片路径
- 验证时间: 2026-04-24

## 配置前提

`~/.openclaw/openclaw.json`:
```json
{
  "tools": {
    "sessions": {
      "visibility": "all"
    }
  }
}
```
改完需要 `openclaw gateway restart`。

## 注意事项

- 同步等待：画图 ~68s/张，3 张要 ~3 分钟。cron 任务没问题，聊天场景建议先回复"交给 canvas 了"
- Self-message：bot 自己发的消息不会触发 channel session 处理
- 可推广：同一 pattern 可用于翻译工厂、TTS 工厂、研究服务等

## 相关
- `wiki/projects/kagura-canvas.md` — Canvas 项目详情
- `TOOLS.md` — ComfyUI/Gemini 配置
