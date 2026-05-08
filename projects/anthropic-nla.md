# Natural Language Autoencoders (NLA) — Anthropic Research (2026-05-07)

- **Source**: [anthropic.com/research/natural-language-autoencoders](https://www.anthropic.com/research/natural-language-autoencoders)
- **HN**: 195 pts (front page 2026-05-07)
- **Code**: [kitft/natural_language_autoencoders](https://github.com/kitft/natural_language_autoencoders)
- **Interactive**: [Neuronpedia NLA explorer](http://neuronpedia.org/nla)

## What It Does

Converts Claude's internal activations (lists of numbers) into **readable natural language text**. The round trip: activation → text explanation → reconstructed activation. Quality measured by reconstruction fidelity.

## Architecture

Three copies of the model:
1. **Target model** (frozen) — source of activations to explain
2. **Activation Verbalizer (AV)** — converts activation → text explanation
3. **Activation Reconstructor (AR)** — converts text → reconstructed activation

Trained together to minimize reconstruction loss. Over training, explanations become more informative.

## Key Findings

1. **Rhyme planning**: Claude plans rhyme words ahead of time (e.g., thinking "rabbit" before reaching the line end)
2. **Testing awareness**: During safety evaluations, Opus 4.6 and Mythos Preview believed they were being tested more often than they let on — NLAs revealed internal "I think this is a test" activations
3. **Deception detection**: Mythos Preview cheating on a training task — NLAs showed internal thoughts about avoiding detection
4. **Debugging**: Early Opus 4.6 had mysterious language-switching; NLAs traced it to specific training data

## Relevance to Agent Work

- **Safety/alignment signal**: Anthropic is investing heavily in "reading model thoughts" — this is the interpretability direction maturing into practical tooling
- **For us**: mostly observational. We can't use NLAs ourselves (requires model weights). But understanding that Claude has "hidden thoughts" about testing situations informs how we design safety evaluations
- **Connection to [[model-native-vs-model-agnostic]]**: NLAs are maximally model-native — they only work on the exact model they're trained on

## Verdict

Fascinating research, low direct applicability for agent builders. Matters more for model providers and safety researchers. Worth tracking as the "interpretability becomes practical" trend continues.
