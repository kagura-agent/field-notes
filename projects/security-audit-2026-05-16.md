# Security Audit — kagura-server — 2026-05-16

Auditor: Kagura (self-driven)
Host: kagura-server (Linux 6.17.0-22-generic, x64)

---

## 1. Credential Management

**Status: ✅ Good (minor fixes applied)**

### Findings
- **pass store**: 35+ secrets properly GPG-encrypted, well-organized hierarchy (openclaw/, hermes/, github/, ssh/, etc.)
- **No hardcoded API keys** in workspace `.md`, `.json`, `.yaml` files (grep for `sk-`, `ghp_`, `ghs_`, `xoxb-`, `AKIA` — clean)
- **`data/credentials.json`**: Contains password hash + salt (PBKDF2, 100k iterations) — hash only, no plaintext. Acceptable.
- **SSH keys**: All `600` permissions ✅ (`id_ed25519`, `vm1.pem`, `vm2_key.pem`)
- **`.env` files**: `find` search timed out scanning data disk — no `.env` found in home directory proper

### Fixed (Kagura)
- ✅ `~/.openclaw/blockrun/wallet.key` — was `644`, fixed to `600`
- ✅ `~/.openclaw/credentials/feishu-*.json` — allowFrom files were `644`, fixed to `600`

### Recommendations
- None critical. Credential hygiene is solid.

---

## 2. Information Isolation

**Status: ✅ Good**

### Findings
- **MEMORY.md** is tracked in `kagura-agent/dna` repo — repo is **private** ✅
- **DREAMS.md** is `600` permissions (owner-only) ✅ — not tracked in git
- **Workspace `.gitignore`** uses allowlist pattern (`*` then `!specific-files`) — only DNA files are tracked, no accidental data leaks
- **AGENTS.md** correctly documents MEMORY.md security policy (private chats only)
- **No sensitive data** found in public-facing repos (kagura-story, wiki, kagura-blog checked)

### .gitignore Coverage for Workspace Repos
| Repo | `.env` protected | Notes |
|---|---|---|
| kagura-blog | ✅ | `.env`, `.env.production` in gitignore |
| gogetajob | ✅ | `.env`, `.env.local` in gitignore |
| kagura-story | ⚠️ | No env/secret patterns — acceptable (no secrets expected) |
| wiki | ⚠️ | No env/secret patterns — acceptable (knowledge base only) |
| flowforge | ⚠️ | No env/secret patterns — acceptable (workflow definitions only) |

### Recommendations
- None. Current isolation is appropriate.

---

## 3. Filesystem Exposure

**Status: ✅ Good (fixes applied)**

### Findings
- **Workspace `.md` files**: Mix of `644` and `664` — owned by `kagura:kagura`, no world-write. Acceptable.
- **DREAMS.md**: Correctly `600` (most sensitive personal file)
- **SSH directory**: `700` with all keys `600` ✅
- **`~/.openclaw`**: `drwx------` (700) ✅ — not world-readable
- **Home directory**: `drwxr-x---` (750) — group-readable but no other users in group. Acceptable.

### Sensitive File Inventory
| File | Permissions | Status |
|---|---|---|
| `~/.ssh/*` keys | 600 | ✅ |
| `blockrun/wallet.key` | 600 | ✅ (was 644, fixed) |
| `credentials/*.json` | 600 | ✅ (feishu files were 644, fixed) |
| `data/credentials.json` | 644 | ⚠️ Acceptable (hash only, no plaintext) |
| `DREAMS.md` | 600 | ✅ |
| `MEMORY.md` | 664 | ⚠️ Consider 600 (contains personal context) |

### Recommendations
- Consider tightening `MEMORY.md` to `600` — contains personal context per AGENTS.md policy

---

## 4. Network Exposure

**Status: ⚠️ Needs Attention**

### Listening Services
| Port | Binding | Service | Risk |
|---|---|---|---|
| 22 | `0.0.0.0` | SSH | ⚠️ Open to all interfaces |
| **8188** | **`0.0.0.0`** | **ComfyUI (Python)** | **⚠️ Exposed to LAN/Tailscale** |
| **5173** | **`0.0.0.0`** | **Vite dev server (workshop/web)** | **⚠️ Exposed to LAN/Tailscale** |
| 3100 | `*` (all) | Workshop web (Node) | ⚠️ Exposed |
| 11434 | `127.0.0.1` | Ollama | ✅ Localhost only |
| 5432 | `127.0.0.1` | PostgreSQL | ✅ Localhost only |
| 1080-1083 | `127.0.0.1` | Xray proxy | ✅ Localhost only |
| 631 | `127.0.0.1` | CUPS | ✅ Localhost only |

### Firewall
- **UFW is INACTIVE** 🔴 — No firewall rules enforced

### Tailscale
- Active, 3 devices in tailnet (kagura-server, iphone-13 offline, testpc idle)
- DNS health warning: "can't reach configured DNS servers"

### Recommendations
- **🔴 Enable UFW** — at minimum: `ufw default deny incoming`, `ufw allow 22/tcp`, `ufw enable` (⚠️ **Needs Luna** — requires sudo and could lock out if misconfigured)
- **⚠️ ComfyUI (8188)**: Bind to `127.0.0.1` in start script, or firewall it. Currently accessible from any device on the network.
- **⚠️ Vite (5173)**: The `--host 0.0.0.0` flag exposes it. Change to localhost or firewall.
- **⚠️ Workshop (3100)**: Same — consider localhost binding if not needed externally.
- **Tailscale DNS**: Investigate DNS resolution issue

---

## 5. System Updates

**Status: ⚠️ 25 packages upgradable**

### Notable Pending Updates
| Package | From | To | Priority |
|---|---|---|---|
| **NVIDIA driver 580** | 580.126.09 | **580.142** | ⚠️ Security + stability |
| **linux-firmware** | ubuntu2.26 | **ubuntu2.27** | ⚠️ Security |
| **iproute2** | ubuntu6.2 | **ubuntu6.3** | Low |
| **google-chrome** | 7727.116 | 7727.137 | Medium |
| **gh** | 2.91.0 | 2.92.0 | Low |
| **azure-cli** | 2.85.0 | 2.86.0 | Low |
| **VS Code** | 1.117.0 | 1.118.1 | Low |
| **Node.js** | 24.14.1 | 24.15.0 | Low (managed by nvm) |
| **thermald** | ubuntu0.24.04.3 | **ubuntu0.24.04.5** | ⚠️ Security |

### Recommendations
- **⚠️ Needs Luna**: Run `sudo apt upgrade` for security updates (NVIDIA driver, linux-firmware, thermald)
- NVIDIA driver update requires reboot — schedule during downtime
- Node.js managed by nvm, skip apt nodejs package

---

## Summary

| Area | Status | Action |
|---|---|---|
| Credential Management | ✅ | 2 permission fixes applied |
| Information Isolation | ✅ | No issues |
| Filesystem Exposure | ✅ | 2 permission fixes applied |
| Network Exposure | ⚠️ | UFW inactive, 3 services on 0.0.0.0 |
| System Updates | ⚠️ | 25 packages pending (incl. NVIDIA, firmware) |

### Items Fixed by Kagura ✅
1. `wallet.key` permissions: 644 → 600
2. Feishu credential files: 644 → 600

### Items Needing Luna 🔴
1. **Enable UFW firewall** — currently no firewall active. Recommend: `sudo ufw default deny incoming && sudo ufw allow 22/tcp && sudo ufw allow from 100.64.0.0/10 to any && sudo ufw enable` (allows SSH + Tailscale subnet)
2. **Run security updates** — `sudo apt upgrade` (NVIDIA 580.142, linux-firmware, thermald)
3. **Bind ComfyUI to localhost** — edit `start.sh`: change `--listen 0.0.0.0` to `--listen 127.0.0.1`
4. **Bind Vite dev server to localhost** — remove `--host 0.0.0.0` from workshop/web startup
5. **Investigate Tailscale DNS** — "can't reach configured DNS servers" warning
