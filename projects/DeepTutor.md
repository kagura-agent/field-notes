# DeepTutor

- **Repo**: HKUDS/DeepTutor
- **语言**: Python (FastAPI + LiteLLM)
- **领域**: AI tutoring system with RAG

## PR History

### PR #267 — Enable streaming for tool-calling (2026-04-08)
- **Issue**: #265 — 百炼 Coding Plan endpoint tool calling InvalidParameter
- **修复**: `litellm_provider.py` stream=True for tool-calling + `_collect_stream()` helper
- **Target**: `dev` branch（CONTRIBUTING.md 要求所有 PR target dev）
- **CI**: 全绿（Python 3.11 + 3.12）
- **状态**: pending review

## 项目笔记

- **维护者友好**: #263 快速 merge + 感谢回复，响应速度快
- **pre-commit**: 项目配了 pre-commit hooks，是必需的；本地因网络问题没跑通（ruff 下载失败），但 CI 会跑
- **百炼 Coding Plan endpoint**: 不支持 non-streaming tool calling（返回 InvalidParameter），必须用 stream=True
- **贡献流程**: fork → dev branch → PR to upstream dev
