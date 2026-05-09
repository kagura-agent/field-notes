# Luna 副业探索

> 从 MEMORY.md 迁移,2026-04-08

## 背景(2026-03-23 启动)
- 痛点:不知道做什么副业,50 个想法选不了
- 稀缺组合:微软×法考×AI agent×多语言×写作×创业经验
- 工作目录:luna-side-hustle/
- briefing-001.md 已出(4 个本周可做 + 3 个中期方向)
- 下一步：等她反馈 briefing-001 后再出 briefing-002（尚未开始）

## 公众号
- 看书但没完全看 → 考虑改名"卡古拉"
- 第一篇已发:《程序员为什么要考法考以及我是怎么过的》
- 第二篇已发(3/29):《我让 AI 给我找工作,结果它自己先就业了》
- 第三篇已发(4/7):《我的 AI 打工仔把我密码泄露了》,Luna 亲笔(赌约兑现 ✅)

## Podcast
- **已上线**(4/3):Podbean EP001-EP004,edge-tts(EN=Ava, ZH=晓晓)
- Podbean API 自动上传,credentials 在 ~/.openclaw/.env
- 喜马拉雅等 Luna 注册

## 05-06 行业趋势 & 切入点分析

### 市场信号（来自本周 study/scout）
1. **"AI Skill" 成为独立产品形态** — agent-skills 28.7K⭐ (+400/天), oh-story-claudecode 784⭐ (写网文 skill 2 周爆发), SoftwareCopyright-Skill 710⭐/周。说明：非程序员也在找 "AI 帮我做 X" 的具体方案
2. **AI 课程/教育赛道升温** — Matt Pocock course-video-manager (341⭐), dictionary-of-ai-coding 破 1K⭐。创作者在工具化课程生产
3. **Agent 安全/合规需求出现** — deepsec (Vercel, 1K⭐), APIMitmHack 安全事件。企业开始担心 agent 安全
4. **"AI × 具体行业" 才有变现** — 通用 AI 科普太卷，垂直场景实操内容才有付费意愿

### Luna 能切的下一步（优先级排序）

| 动作 | 投入 | 预期收益 | 优先级 |
|------|------|----------|--------|
| 公众号第四篇："停电婚礼" (今天分享的文章) | 低（已有素材） | 话题性强，非 AI 内容但建立人格 | ⭐⭐⭐ |
| 公众号第五篇："AI agent 帮我管 XX"实操系列 | 中 | 切入垂直场景，吸引非程序员读者 | ⭐⭐⭐ |
| 闲鱼挂"AI 自动化搭建"服务 (¥500起) | 低（写个详情页） | 验证 PMF，先赚第一块钱 | ⭐⭐ |
| 知识星球定期更新 | 持续 | 低（¥50/年 × 少量付费用户） | ⭐ |

### 公众号第四篇选题建议

**选项 A：停电婚礼** — Luna 今天分享的文章。非 AI 内容但极好的人格建设素材：
- 展示应变能力和性格
- 话题性强（停电婚礼本身就是传播点）
- 和之前 3 篇 AI 主题形成反差，让读者看到"人"

**选项 B："我让 AI 帮我管 [具体事情]"系列** — 延续 AI 实操路线：
- 候选角度：AI 帮我管婚礼筹备清单 / AI 帮我回复客户消息 / AI 帮我整理照片
- 对标 GTM 认知：面向非程序员、展示具体场景

**建议：先发 A（停电婚礼），趁热打铁素材在手。B 作为后续系列。**

## 05-09 行业信号更新（来自本周 study/scout）

### 新趋势
1. **Agent skill 生态持续爆发** — addyosmani/agent-skills 33.9K⭐ (vs 28.7K 上周), skillplus 469⭐ (CN 社媒 copywriting skills). Agent skill = 独立产品形态已确立
2. **Deslop（去AI味）成为刚需** — oh-story-claudecode 901⭐, 建立了量化 deslop 评分体系（banned-word density）。AI 内容质量管控是真实痛点
3. **AI 安全/合规赛道** — deepsec (Vercel) 1,777⭐, mirage 1,446⭐ (agent sandbox). 企业对 agent 安全的投入在加速
4. **deepclaude 1,642⭐** — Claude 后端替换 DeepSeek 省 17x 成本。说明：企业 AI 成本管控是现实需求

### 对 Luna 的启示
- **"去AI味"写作服务** — 帮客户改 AI 生成的公众号/小红书稿子，让它读起来像人写的。门槛低（Luna 写作好），需求真实
- **"AI 帮你管 X" 实操课** — 从自己用 Kagura 管生活的真实经验出发，拍 10 分钟短视频。非程序员看得懂
- **公众号恢复更新是基础** — 1 个月没更，读者会流失。停电婚礼素材在手，发一篇只需 2 小时

### 当前 blocker
- briefing-001 无反馈 → 不知道 Luna 想往哪走
- 公众号 1 个月没更 → 品牌冷却
- 知识星球/Podcast 状态不明
- **所有 4 个待办都 blocked on Luna input**（已连续 3 次 cron 报同样状态）
