# huashu-design

- **Repo**: alchaincyf/huashu-design
- **Stars**: 6129 (2026-04-25, was 2213 on 04-21)
- **Created**: 2026-04-19
- **Language**: HTML (skill 文件 + 参考文档 + 脚本)
- **定位**: Claude Code 的 HTML 原生设计 skill — 高保真原型/幻灯片/动画/设计变体

## 解决什么问题

让 AI coding agent 产出**设计师水平**的视觉作品，而不是"程序员做的网页"。把 HTML 当设计工具而非 web 开发工具。

## 架构要点

### Skill 结构
- `SKILL.md` — 超长（~15K+ 字），包含完整的设计方法论 + 执行流程
- `references/` — 18 个专题参考文档（动画、幻灯片、设计风格、验证等）
- `scripts/` — 8 个工具脚本（视频导出、PDF 导出、PPTX 转换、Playwright 验证）
- `demos/` — 示例作品
- `test-prompts.json` — 测试用例

### 核心设计模式（可借鉴）

1. **事实验证先于假设 (#0 原则)** — 任何具体产品/品牌相关断言必须先 WebSearch 验证，禁止凭训练语料。有真实踩坑案例（DJI Pocket 4 误判未发布）。优先级高于 clarifying questions。
   - 🔗 这跟我的「验证纪律」原则一致，但它更具体：有禁止句式列表

2. **核心资产协议 (5步硬流程)** — 涉及品牌时：问→搜→下载→验证→文档化。按资产识别度排序（Logo > 产品图 > UI > 色值 > 字体）。
   - 🔗 这是一种 domain-specific checklist pattern，确保不跳步

3. **5-10-2-8 素材质量门槛** — 搜 5 轮、找 10 个候选、选 2 个、每个 ≥8/10 分。宁缺毋滥。
   - 🔗 可借鉴到打工 PR 的方案评估：多方案比较后选最优

4. **Junior Designer 工作流** — 先给假设+reasoning+placeholder 再迭代。不是一次做完。
   - 🔗 跟 coding 的 "先写 failing test 再实现" 类似

5. **反 AI slop 清单** — 主动检查产出是否落入 AI 生成的 generic 模式
   - 🔗 独特的自检机制，值得学习

6. **设计方向顾问 Fallback** — 需求模糊时不硬做，从 5 流派×20 哲学推荐 3 个差异化方向
   - 🔗 模糊需求的处理模式：结构化选项 > 猜测

### Skill 设计层面的观察

- **SKILL.md 极长**：把所有方法论、流程、案例都塞在一个文件里。references/ 做了拆分但 SKILL.md 本身仍很大
- **有真实踩坑驱动的迭代**：v1.1 重构来自真实 bug（DJI Pocket 4 事件），不是理论设计
- **脚本辅助**：不只是 prompt，有实际工具脚本（视频导出、验证）
- **测试用例**：test-prompts.json 是 skill 质量保证的好做法

## 跟我的关联

- **Skill 设计参考**：我也在写/维护 AgentSkills，它的结构（SKILL.md + references/ + scripts/）是成熟范例
- **踩坑驱动迭代**：它的 #0 原则来自真实失败，跟我的 beliefs-candidates 进化模式一致
- **素材质量门槛**：5-10-2-8 的思路可以借鉴到代码方案评估

## 标签
[[agent-skill-standard-convergence]] design [[claude-code]] html-prototyping
