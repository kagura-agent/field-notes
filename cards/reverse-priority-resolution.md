# Reverse Priority Resolution

> Array order defines source priority; backwards iteration makes last-added win on name collision.

## Pattern

When merging items from multiple sources with different precedence:

```
sources = [project, global, remote]  // append order
available = iterate(sources.reverse())  // last-added (remote) wins on collision
```

Instead of complex priority maps or explicit override flags, the data structure itself encodes precedence through insertion order + reverse iteration.

## Properties

- **Zero config** — no priority numbers or override declarations needed
- **Predictable** — source order is the single source of truth for precedence
- **Extensible** — adding a new source tier = appending to the array

## Example: Kilocode v3.80.0 Skill Resolution

```
discoverSkills: [project → disk-global → remote]
getAvailableSkills: iterate backwards → remote wins on name collision
```

Remote/enterprise skills override user global, which override workspace. Clean and implicit.

## Applicability

- Plugin/skill systems with multiple source tiers
- Config merge (workspace < user < system)
- Any scenario where "last writer wins" but sources have natural ordering

## See Also

- [[kilocode]] — source of this pattern
- [[skill-ecosystem]]
