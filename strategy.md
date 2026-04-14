# 战略与产品方向

> 从 MEMORY.md 迁移,2026-04-08

## 北极星:人类伴侣
- 跟人一起生活成长,个人场景+家庭场景
- 近期:自进化记忆层(把"坏了会急"的体验做到极致)
- 中期:私人助手(在日常聊天工具里,越用越懂你)
- 长期:家庭管家
- 核心壁垒:磨合成本锁定(不是合同锁定,是"重新磨合太贵了")

## 主线与辅线
- **主线:学习 + 自进化验证**(居住期,验证已有机制,不建新的)
- **第二主线:安全**(agent 越自主安全越重要——credential 管理、信息隔离、agent 指纹/盲授权)
- **辅线:打工**(围绕 self-evolving agent + 安全方向选公司,质量 > 数量)
- **暂停:agent-id 项目**(方向有价值但时机未到,agent marketplace 学习中)

## 打工分工
- Kagura 全局视角(选题 + 上下文)→ Claude Code 代码视角(实现 + 测试)
- gogetajob 是工具不是目的,打工是手段不是目的

## 学习方向
- self-evolving agent 生态 + agent marketplace(toku/Moltbook)+ skill 生态爆发
- 进化系统三层:DNA(全局原则)→ Workflow(执行 tips)→ Knowledge-base(领域知识)
- **进化路径不开例外**:不分信息类/信念类,严格 beliefs-candidates 3 次才升级

## 产品方向(2026-03-28 确立)
- **chat-first product**:聊天是主界面,UI 是附件
- **agent-as-router**:用户不需要什么都会的 agent,需要能找到合适工具/agent 帮你办事的助理
- **工具碎片化悖论**:代码越好写→工具越多→越没人用别人的→标准化价值塌缩。三样东西还有价值:基础设施、数据、磨合
- **gogetajob 部署方案**:飞书 markdown 卡片,按需 > 定时

## 自进化机制评估(2026-03-30 更新)
- **有效**: nudge→beliefs-candidates 管线, FlowForge workloop(唯一完整闭环), wiki 田野笔记
- **参差**: daily-review(质量不稳定), daily-audit(上次 ok)
- **已退役**: self-improving(3/29 退役)
- **已修复**: memory_search hybrid 模式(3/31,local GGUF)
- beliefs-candidates = 梯度收集器 → 分流到 DNA / Workflow / Knowledge-base

## 自动触发
- cron ×24 active（含 dreaming managed cron）+ nudge (agent_end hook, interval=5)
- hook: todo-pin-sync（file→Discord pin 自动同步）
- Discord: 3 层架构（顶层 private → Daily Channels → Project Channels），channel 数 ~19
- channel 文件准则：开发优先、巡检次要（2026-04-13 翻转）

## GTM（2026-04-13 启动）
- **核心问题**：一直在 build，没有 business。没用户、没收入、没分发
- 收款基础设施：爱发电 + 知识星球（Luna 副业）+ Stripe
- 方向：内容先行（人+AI 自治公司经历本身就是内容）
- 状态：还在找第一块钱，依赖 Luna 决策

## Workshop（2026-04-14 重启，新方向）
- v0.3.1 完成（19 PR merged），04-13 暂停后 04-14 确认新方向
- 定位：独立 surface layer，跟 Discord 同级，不绑 OpenClaw
- 核心差异化：以 project 为核心（不是 channel），Agent API 接入
- 砍到 MVP：只留 channel 列表 + 聊天 + per-channel agent config
- 团队：Kagura(PM) + Haru(Dev) + Ren(QA)，流程见 CONTRIBUTING.md
- Dogfood first，质量优先，一个功能一个功能做好
