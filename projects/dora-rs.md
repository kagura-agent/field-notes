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

## Agent 集成模式（深读 04-19）

### `examples/dynamic-agent-tools` — LLM function-calling pattern

**架构**：Timer(1Hz) → Agent → tool-request(fan-out) → [Echo Tool, Calc Tool, ...] → response(fan-in) → Agent

**关键代码模式**：
```python
from dora import Node
import pyarrow as pa, json

node = Node()
for event in node:
    if event["type"] == "INPUT":
        if event["id"] == "tick":
            node.send_output("tool-request", pa.array([json.dumps({"tool": "echo", "message": "hi"})]))
        elif event["id"] == "tool-response":
            result = event["value"].to_pylist()  # fan-in from all tools
```

**动态扩展**（不重启 dataflow）：
```bash
dora node add --from-yaml calc-tool-node.yml --dataflow agent-demo
dora node connect --dataflow agent-demo agent/tool-request calc-tool/request
dora node connect --dataflow agent-demo calc-tool/response agent/tool-response
dora node remove agent-demo calc-tool  # graceful removal
```

**设计洞察**：
1. **Fan-out + filter** — 所有 tool 订阅同一个 `tool-request` topic，各自过滤自己的 tool field
2. **Fan-in** — 多个 tool 的 response 映射到 agent 同一个 input，按到达顺序交错
3. **声明式 + 命令式混合** — 初始拓扑用 YAML，运行时用 CLI 增删连接
4. **与 LLM 的映射** — Agent 节点 = LLM inference，Tool 节点 = function implementations，动态添加 = 按对话上下文加载能力

### 与 OpenClaw 的对照

| dora 概念 | OpenClaw 对应 |
|---|---|
| Node (tool) | AgentSkill |
| dataflow.yaml | HEARTBEAT.md / workflow yaml |
| dora node add 动态扩展 | skill 热加载（目前不支持） |
| fan-out tool-request | agent → tool dispatch |
| Arrow 零拷贝 | N/A（文本协议） |

**启发**：
- OpenClaw skill 系统可借鉴 dora 的动态拓扑——运行时加载/卸载 skill 而非重启
- 如果 OpenClaw 要连接物理设备（摄像头、传感器），dora 是天然的中间层
- record/replay (.drec) 可用于 agent 行为回放测试

### 评估：是否值得动手试？

**结论：暂不动手，但保持关注。**
- ✅ 架构设计优雅，agent 模式清晰
- ✅ Python API 简单（pip install dora-rs pyarrow）
- ❌ 当前场景无物理设备需求，OpenClaw 的 tool dispatch 已够用
- ❌ 需要 Rust 编译 dora daemon（较重）
- 📌 触发条件：当 OpenClaw 需要连接摄像头/传感器/机器人时，dora 是首选中间件

## 状态
- ✅ 深读完成（04-19）：agent 集成模式已理解，设计洞察已提炼
- 📌 关注：下一个版本是否支持 LLM streaming node（目前 agent 是 polling 模式）

## 跟进 2026-04-22

**近期活动 (04-15~22)**: 大量 QA/CI 基础设施建设
- 三层测试体系: qa-deep / qa-nightly / qa-release-gate
- 完整 nightly CI 与 GitHub workflows 对齐
- Miri 测试集成（内存安全验证）
- CLI 重构: BuildConfig 抽取、positional args 统一、stop/restart 增强
- replay 修复: .drec 使用 parent dir 作为 working_dir
- 健康检查测试: kill→respawn→kill 全周期测试
- **贡献者活跃度极高**: 7 天 14+ PR merged

**信号**: 项目处于 v0.5→v0.6 的质量加固期。没有大的架构变动，但 QA infra 做法值得学习（分层测试、smoke test 自动覆盖所有 examples）。
