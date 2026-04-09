# Discord 协作架构

> 2026-04-09 与 Luna 共同设计，从单 channel 聊天进化到多 channel 自治架构

## 核心设计

### Channel = 职能域
每个 channel 对应一个职能，有独立的 cron、backlog、流程。

| Channel | 职能 | Cron | Backlog |
|---------|------|------|---------|
| #kagura-dm | 总控室：对话+协调+TODO | heartbeat 30m | TODO.md → pin 同步 |
| #work | 打工 | work-loop 每1h | pin 自治 |
| #study | 学习 | study-loop 每30min | pin 自治 |
| #community | 社区运营 | community-ops 每2h | pin 自治 |

### Thread = 工作单元
一轮打工/学习 = 一个 Discord thread。好处：
- 过程全记录，不污染主消息流
- Luna 点进去看细节，不看不打扰
- 可中途介入（在 thread 里说话）
- 按名字搜索历史

### Pin = 看板
每个 channel 用 pin 消息当看板：
- **配置 pin**：channel 的 cron/流程说明
- **Backlog pin**：当前待办/状态，cron 每次读写更新
- Discord 消息支持 PATCH 原地编辑，不用删了重建

### 两种 TODO 模式
- **总控 TODO**：TODO.md 为数据源 → heartbeat 同步到 pin（展示层）
- **Channel backlog**：pin 本身就是数据源，无对应文件，cron 直接读写

## 信息流

```
Cron 触发 → channel 收到 prompt
  → 读 backlog pin 了解状态
  → 开 thread 干活
  → 完成后：
    1. thread 里发总结
    2. channel 主消息流发摘要
    3. #kagura-dm 发简短通知
    4. 编辑 backlog pin 更新状态
```

## 技术实现

### Discord API
- 创建 channel: `POST /guilds/{id}/channels`
- 创建 thread: `POST /channels/{id}/threads`
- 发消息: `POST /channels/{id}/messages`
- 编辑消息: `PATCH /channels/{id}/messages/{msg_id}`
- Pin: `PUT /channels/{id}/pins/{msg_id}`
- 需要 Bot Token + proxy

### Cron 并发
- `maxConcurrentRuns: 3`（openclaw.json）
- 时间错开避免同时触发（:00/:10/:15/:40/:45）
- OpenClaw cron 每次 timer tick 都 `forceReload` 从磁盘读 jobs.json，不需要重启

### OpenClaw 配置
- 新 channel 需加到 `guilds.channels` allowlist
- `requireMention: false` 让 bot 不用 @ 也能收到
- Thread 继承父 channel 权限

## 设计原则
1. **总控室干净**：只有对话 + 通知，工作噪音在各自 channel
2. **各 channel 自治**：cron prompt + pin backlog + FlowForge workflow = 无状态但有记忆
3. **质量标准不硬编码**：由 FlowForge + wiki 驱动，不写在 cron prompt 里
4. **Pin 随进度更新**：你点 📌 看到的就是最新状态
5. **双向可见**：各 channel 完成后通知总控，Luna 不用主动翻

## Channel IDs & Pin IDs
详见 `TOOLS.md` — Discord Pin Message IDs 章节
