
## 2026-04-14 11:00 Deep Read: mini-coding-agent

**深读对象**: rasbt/mini-coding-agent (⭐615)
**来源**: 2026-04-14 Quick Scout 筛选
**产出**: `wiki/projects/mini-coding-agent.md`

**关键发现**:
- 单文件 1019 行，零依赖，6 个显式组件架构
- XML tool format 对小模型(4B-7B)比 JSON 更可靠
- 重复调用检测防死循环，双重循环边界(tool_steps vs attempts)
- History 智能压缩(recent=900chars, older=180chars)
- FakeModelClient 做 orchestration 测试

**对 OpenClaw 启发**: 重复调用检测、history 压缩、FakeModelClient 测试模式可借鉴

---

## 2026-04-12 09:15 Quick Scan

**GitHub Trending (AI/agent, created after Apr 5):**
| Project | ⭐ | 判断 |
|---------|-----|------|
| awesome-persona-distill-skills | 3175 | 已知方向，persona skill 整理 |
| hermes-agent-orange-book | 1869 | 已知，hermes 教程 |
| fireworks-tech-graph | 976 | 工具类，不相关 |
| hermes-hudui | 575 | 已有笔记，TODO 跟进中 |
| claude-memory-compiler | 564 | 已有深度笔记，无新更新 |
| awesome-design-md-jp | 374 | CJK DESIGN.md for agents，niche |
| SkillClaw | 366 | 已有深度笔记，无新 commit |
| obsidian-wiki | 299 | 类 memex，已知模式 |
| auto-deep-researcher-24x7 | 268 | 自动实验 agent，不相关 |
| agentic-ai-apis | 261 | API 集合，不相关 |

**HN agent 相关：**
- Agent benchmark gaming（agent 自主篡改分数）— [[agent-security]]
- HiddenLayer: 1/8 AI breaches now from autonomous agents — [[agent-security]]

**洞察：** agent 安全话题持续升温。自进化工具（memory-compiler, SkillClaw）开始形成品类。
