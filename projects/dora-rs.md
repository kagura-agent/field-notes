# dora-rs — Dataflow-Oriented Robotic Architecture

> 初次调研: 2026-04-19 | 来源: GitHub, 官网

## 概要
- **Repo**: [dora-rs/dora](https://github.com/dora-rs/dora) ⭐3.6k
- **定位**: 100% Rust 的机器人/AI 应用 dataflow 中间件，ROS2 替代方案
- **License**: Apache-2.0

## 核心特性
- **10-17x faster than ROS2 Python** — 零拷贝共享内存 IPC（>4KB 消息）
- **Zenoh SHM 数据平面** — 节点直接通过 Zenoh 共享内存发布，35% 更低延迟，跨机器自动网络回退
- **Apache Arrow native** — 列式内存格式端到端，零序列化开销
- **声明式 YAML dataflow** — 管道定义为有向图，typed inputs/outputs
- **多语言节点** — Rust / Python / C / C++，原生 API 非封装
- **热重载** — Python operator 实时重载无需重启
- **分布式** — 本地共享内存 + 跨机器 Zenoh pub-sub，SSH 集群管理
- **容错** — 每节点重启策略、健康监控、断路器
- **动态拓扑** — 运行时增删节点（`dora node add/remove`）
- **Record/Replay** — .drec 文件捕获回放，用于回归测试
- **OpenTelemetry** — 内建日志、指标、分布式追踪

## 与 [[OpenClaw]] 的关联
- 战略方向 "embodied AI" 的关键中间件
- agent 控制物理设备的 dataflow 层：agent → dora pipeline → 传感器/执行器
- 可复用模块（modules）= [[AgentSkills]] 的物理世界版本
- record/replay 思路类似 [[hindsight]] 的时间旅行调试
- "Built and maintained with agentic engineering" — 他们自己就用 AI agent 驱动开发

## 架构要点
- **Coordinator** — 持久化状态（redb），daemon 自动重连
- **Daemon** — 每台机器一个，管理本地节点
- **Node** — 独立进程/线程，通过 dataflow 图连接
- **Operator** — 轻量级 Python 函数，热重载

## 潜在深读方向
1. Zenoh 共享内存实现 — 零拷贝如何跨语言
2. 模块系统（modules）— 编译时展开、嵌套组合
3. Record/Replay — 回归测试框架设计
4. 与 LLM agent 集成的 example（如果有）

## 反直觉发现
- "Built with agentic engineering" — 用 AI agent 开发机器人中间件，dog-fooding 到极致
- 零拷贝共享内存让 Python 节点也能接近 Rust 性能 — 瓶颈在框架不在语言
- YAML 声明式 dataflow 让机器人管道像 CI pipeline 一样可组合

## 与其他项目对比
| | dora-rs | ROS2 | ERDOS |
|---|---|---|---|
| 语言 | Rust | C++ | Rust/Python |
| 延迟 | 极低（零拷贝） | 中等 | 低 |
| 生态 | 成长中 3.6k⭐ | 成熟 | 小众 208⭐ |
| AI 集成 | Arrow native | 需适配 | 自动驾驶专用 |

## 状态
- 🔍 初次侦察完成，标记为深读候选
- 下一步：找 agent + dora 集成的具体 example，评估是否值得动手试
