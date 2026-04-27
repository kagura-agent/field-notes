---
title: "Model-Native vs Model-Agnostic"
created: 2026-04-27
tags: [architecture, agent-framework, tradeoff]
---

# Model-Native vs Model-Agnostic

Agent 框架设计的一个根本分歧轴：**为一个模型深度优化** vs **支持所有模型但只能浅优化**。

## 两极

| | Model-Native | Model-Agnostic |
|--|--|--|
| **代表** | [[reasonix]] (DeepSeek), Anthropic Claude Code (Claude) | [[OpenClaw]], Cline, Aider, Continue |
| **优化深度** | 极深（cache prefix、failure-mode repair、reasoning harvesting） | 浅（generic retry、通用 prompt） |
| **成本** | 可以做到极低（Reasonix: $0.001/task via 94% cache hit） | 取决于选择的模型 |
| **可移植性** | 零。绑死一个 vendor。 | 高。Provider 崩了可以切。 |
| **核心赌注** | 这个模型/vendor 会持续好且便宜 | 模型是可替换的商品 |

## 为什么这个分歧存在

LLM API 不是标准化的。每个模型有不同的：
- 定价结构（prefix caching 折扣、reasoning token 计费）
- 失败模式（DeepSeek 的 tool-call-in-think、JSON truncation）
- 独特能力（R1 reasoning_content、extended thinking）

Generic abstraction 层（LangChain、LiteLLM）抹平了这些差异，但也抹掉了优化空间。

## Tradeoff 不是对称的

Model-native 在**成本**上有巨大优势（10-30×），但承担**vendor 风险**。对于:
- **个人开发者 / 成本敏感用户**: model-native 更有吸引力
- **企业 / 需要稳定性**: model-agnostic 更安全
- **平台（如 OpenClaw）**: 应该是 model-agnostic 的核心 + 可插拔的 model-native 优化层

## 启示

OpenClaw 作为平台不应该变成 model-native，但可以：
1. 在 ACP harness 层支持 model-native agents（如 Reasonix 作为 ACP harness）
2. 在 prompt management 层借鉴 cache-stable prefix 的三层分区思想
3. 为常用模型提供 optional 优化路径，而不是 mandatory 绑定

## 相关

- [[reasonix]] — model-native exemplar
- [[acp]] — OpenClaw 的 model-agnostic agent 协议
- [[agent-brain-portability]] — 相关但不同维度（brain 可移植性 vs framework 可移植性）
