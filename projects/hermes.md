
## 本地测试环境（2026-03-28 配置）
- **Python**: 需要 3.11+（本地用 pyenv 3.12.12）
- **venv**: `cd ~/repos/forks/hermes-agent && . .venv/bin/activate`
- **测试命令**: `pytest tests/ --ignore=tests/integration --ignore=tests/acp -q`
- **结果**: 6260 passed / 9 fail（transcription/CUDA 相关，跟我们的 PR 无关）
- **安装**: `pip install -e ".[dev]"`
- acp 测试需要额外依赖（`import acp`），跳过即可
