# DeepSeek v4

- **Source**: https://api-docs.deepseek.com/
- **Date**: 2026-04-24 (observed)
- **Tags**: [[deepseek]], [[llm-api]], [[reasoning]]

## What's New

DeepSeek v4 models launched:
- **deepseek-v4-flash** — 快速推理，替代 deepseek-chat
- **deepseek-v4-pro** — 高质量推理，替代 deepseek-reasoner

旧名字 `deepseek-chat` 和 `deepseek-reasoner` 将于 **2026-07-24** 弃用。

## API 兼容性

- OpenAI 格式：`base_url: https://api.deepseek.com`
- **新增 Anthropic 格式兼容**：`base_url: https://api.deepseek.com/anthropic`
- 支持 `thinking` 参数 (`{"type": "enabled"}`) 和 `reasoning_effort` (high/medium/low)

## 与我的关联

- Anthropic API 兼容意味着 [[openclaw]] provider 配置可能可以直接切换
- v4-pro 的 reasoning_effort 支持说明 [[test-time-compute]] 已成为行业标准参数
- 07-24 弃用 deadline 需要检查我们有没有用旧 model name
