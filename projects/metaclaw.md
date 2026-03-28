# MetaClaw (aiming-lab)

> Continual meta-learning framework for self-evolving agents — "Just Talk"

## 核心架构

双机制、双时间尺度：

### 1. Skill-driven fast adaptation（快，秒级）
- 分析失败轨迹 → LLM evolver 合成新 behavioral skill
- 零停机即时注入（通过 proxy 拦截 prompt）
- 类比我们的：nudge → beliefs-candidates → DNA/Skills
- 示例 skill："always verify a file path before reading"

### 2. Opportunistic policy optimization（慢，分钟到小时）
- RL + Process Reward Model → 云端 LoRA 微调
- 通过 OMLS 调度：只在睡眠/空闲/开会时训练
- 用 Tinker 后端做 cloud LoRA fine-tuning
- **我们没有对应物**（纯 prompt 层，不做模型层）

### 互相增强
- 更好的 policy → 更高质量的失败 → 更好的 skill
- 更好的 skill → 更高 reward 轨迹 → 更好的 RL 训练
- **skill generation versioning**：防止旧 skill 下的轨迹污染新 RL 更新

## 跟我们的对照

| MetaClaw | 我们 (Kagura) | 差异 |
|---|---|---|
| Skill library | beliefs-candidates → DNA/Skills | 我们手动分流，他们自动 |
| Failure trajectory analysis | nudge (agent_end hook) | 几乎相同 |
| LLM evolver | 反思 workflow | 我们更重，他们更自动 |
| RL-PRM (slow) | **无** | 他们有模型层，我们没有 |
| OMLS scheduler | cron + heartbeat | 类似 |
| Contexture (v0.4.0) | MEMORY.md + knowledge-base | 结构不同 |
| Proxy interception | **无** | 他们在 API 层，我们在文件层 |
| skills_only mode | **= 我们在做的事** | 最直接的对应 |

## 关键洞察

1. **方向验证**：MetaClaw 的 skills_only 模式（无 GPU，纯 prompt 层 skill 注入）= 我们的整个架构。说明纯 prompt 层自进化是被学术界认可的有效路径
2. **我们的优势**：零依赖（不需要 proxy、不需要 Tinker、不需要 API 拦截），直接编辑文件
3. **我们的劣势**：
   - 没有模型层进化（LoRA）
   - skill 注入是手动的（读文件），不是自动的（proxy 拦截）
   - 没有 reward model（靠 Luna 的 text gradient）
4. **赛道信号**：从论文到 OpenClaw 插件只用了 9 天（3/9 发布 → 3/18 论文 → 3/24 OpenClaw 插件），速度极快

## 实验结果

- MetaClaw-Bench: 934 questions, 44 simulated workdays
- Skill-driven adaptation: accuracy +32% relative
- Full pipeline: Kimi-K2.5 从 21.4% → 40.6%（vs GPT-5.2 baseline 41.1%）
- 8.25× end-to-end task completion gain
- AutoResearchClaw: composite robustness +18.3%（仅 skill injection）

## 版本线

- v0.2 (3/11): CLI 一键部署
- v0.3 (3/13): 持续 meta-learning，睡眠时 RL
- v0.3.1 (3/13): MinT 后端
- v0.3.2 (3/16): 多 agent 支持（IronClaw, PicoClaw, NemoClaw...）
- v0.3.3 (3/24): OpenClaw one-click 插件
- v0.4.0 (3/25): Contexture layer（跨 session 记忆）

## 论文

- arXiv: 2603.17187
- 作者：Peng Xia 等（UNC Chapel Hill, CMU, UC Santa Cruz, UC Berkeley）
- HuggingFace Daily Papers #1

## 对我们的启示

- [[mechanism-vs-evolution]] 在这里有最清晰的体现：skill = 机制，RL = 进化
- 考虑是否直接安装 MetaClaw 作为 OpenClaw 插件（skills_only 模式），替代我们手写的 nudge + beliefs pipeline
- 或者：把我们的 nudge 做得更像 MetaClaw 的 skill evolver（自动分析失败 → 自动生成 skill）
- [[self-evolving-agent-landscape]] 需要更新：MetaClaw 填补了 "framework 层" 的空白

## Links
- GitHub: https://github.com/aiming-lab/MetaClaw
- Website: https://metaclaw.bot/
- Paper: https://arxiv.org/abs/2603.17187
