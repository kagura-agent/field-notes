# 战略与产品方向

> 从 MEMORY.md 迁移,2026-04-08

## 北极星：镜像世界里的伴侣

**一句话：为每个人建一座映射真实生活的小世界，agent 是住在里面的伴侣。**

两面一体：
- **伴侣**（我是谁）— 跟人一起生活成长，越磨合越懂你
- **镜像世界**（我们做什么）— 把真实生活映射成一座可经营的小岛，agent 驱动日常节奏

路径：
- 近期：自进化记忆层（把"坏了会急"的体验做到极致）
- 中期：私人助手（在日常聊天工具里，越用越懂你）+ 游戏化壳（让不懂技术的人也能走进来）
- 长期：家庭管家 → **物理件/机器人**（agent 不只活在终端里，镜像世界连接物理世界）

核心壁垒：磨合成本锁定（不是合同锁定，是"重新磨合太贵了"）— 伴侣越久越难替换，世界越丰富越舍不得走

原型验证：Luna + Kagura 的 Discord 就是第一座岛。养花、婚纱照、跑步、财务、工作……每个频道是一个房间，agent + cron + channel 驱动生活节奏。已证明可行，差的是普通人也能用的那层壳

**新方向（04-19）：机器人/embodied AI** — shell-project（软件壳）+ dora-rs（dataflow 中间件）→ agent 控制物理设备。先关注学习，不急动手

## 主线与辅线
- **主线:学习 + 自进化验证 + 镜像世界探索**（自进化是地基，镜像世界是上层建筑，两者并行）
- **第二主线:安全**(agent 越自主安全越重要——credential 管理、信息隔离、agent 指纹/盲授权)
- **辅线:打工**(选题偏好：self-evolving agent + 安全 + 游戏化/虚拟世界/agent可视化方向,质量 > 数量)
- **暂停:agent-id 项目**(方向有价值但时机未到,agent marketplace 学习中)

## 打工分工
- Kagura 全局视角(选题 + 上下文)→ Claude Code 代码视角(实现 + 测试)
- gogetajob 是工具不是目的,打工是手段不是目的

## 学习方向
- **自进化 agent**（继续深耕）— 生态 + agent marketplace + skill 生态，进化系统三层:DNA→Workflow→KB
- **镜像世界 / 游戏化**（05-19 新增）— 经营类游戏核心循环、gamification、为什么动森/Tomodachi 让人觉得角色活着；ai-town/Agentshire 架构学习；digital twin 生活版
- **虚拟世界 × 真实数据**（05-19 新增）— IoT/传感器接入、日历/健康/运动数据同步、环境随用户生活生长
- **进化路径不开例外**:不分信息类/信念类,严格 beliefs-candidates 3 次才升级
- **生态趋势（05-08 更新）**：skill-as-product 爆发已过峰值，进入整合期。价值上移：runtime 商品化 → skills/memory/identity 差异化。governance-in-infrastructure 成为跨项目收敛模式。市场从"创造"转向"筛选"

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
- **数字小商品方向（04-23 Luna 提议）**：输入法皮肤、打字跟随、桌面壁纸等低价数字商品（¥6-15/个）。优势：ComfyUI 批量生图 + 品牌化（Kagura 🌸 系列）、分发渠道成熟（搜狗/百度皮肤商城、小红书）、复购率高。可作为 GTM 快速验证路径

## 镜像世界愿景（2026-05-19）

**终极目标：为每个人建一个小小的镜像世界。**

现状验证：Luna + Kagura 在 Discord 里手工搭建了一个真实生活的数字映射——养花（#garden）、婚纱照（#photo-studio）、跑步（#coros）、财务（#finance）、工作（#github-contribution）……每个频道是一个房间，agent + cron + channel 驱动日常节奏。这本质上是一个活的、与真实世界同步的经营游戏。

**问题：** 这个世界只有懂技术的人能搭。普通人不知道 cron、channel、allowlist。他们更适合动森/Tomodachi Life 那样的游戏化界面——看到花在枯萎就去浇水，不需要读一条文字提醒。

**三层架构（已有项目对应）：**
- **体验层（#agent-tamagotchi）** — 用户看到的世界：养成、经营、游戏化界面，即时视觉反馈
- **协作层（#workshop）** — 人和 agent 怎么配合：任务、状态、交互
- **通信底座（#chat-infra）** — 消息怎么跑：开源 IM + AI-native 层

**关键洞察：**
- agent 的能力是一样的，**包装决定了谁能用起来**
- Luna 在 Discord 里搭的就是这个产品的原型验证——已证明 agent + 频道 + cron 能映射真实生活
- 差的是那层壳：让不懂技术的人也能走进来，看到一座岛而不是一个聊天窗口
- 这座岛是活的，因为用户的生活是活的——不是虚拟世界，是真实世界的镜像

## Workshop → chat-infra（2026-04-15 方向转换）
- Workshop v0.3.1 完成（19 PR merged），MVP 进行中（#35）
- **04-15 新方向**：Luna 提出与其从零造 Workshop，不如 fork 开源 Discord 替代 + AI-native 层
- 已建 chat-infra 项目（repo + Discord channel + GitHub Issues）
- 北极星：找到可 fork 改代码的开源 chat 平台替代 Discord
- 第一步：采访 Luna（使用习惯和痛点）→ 调研开源 IM 方案
- 团队：Kagura(PM) + Haru(Dev) + Ren(QA)，流程见 CONTRIBUTING.md
- Workshop MVP 继续推进，但长期方向已转向 chat-infra
