# Self-Improving

自我改进机制——agent 通过反馈循环持续提升执行质量。

## 状态
原 `self-improving` 机制于 2026-03-29 退役，功能由更具体的组件替代：
- [[beliefs-candidates]] — 梯度收集
- [[beliefs-upgrade-mechanism]] — 升级路径
- nudge plugin — agent_end hook 触发反思

## 相关
- [[self-evolution-architecture]]
- [[eval-driven-self-improvement]]
