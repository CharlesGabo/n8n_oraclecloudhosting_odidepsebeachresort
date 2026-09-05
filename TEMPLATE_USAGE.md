# Reusing This Workspace

The root project remains the current live migration workspace. Generate future
projects with the safe PowerShell generator; do not copy the root directory
manually because it may contain ignored backups or workflow exports.

## Create a future project

Run from this repository in PowerShell:

```powershell
.\New-N8nOracleProject.ps1 `
  -Destination C:\path\to\new-n8n-project `
  -Domain n8n.example.com `
  -N8nVersion 2.22.6 `
  -AcmeEmail admin@example.com `
  -Timezone Asia/Manila
```

The destination must be new or empty. The generator deliberately excludes:

- `.env` and all secrets;
- `backups/` and `exports/` contents;
- this project's populated migration inventory;
- databases, credentials, certificates, and SSH keys.

It creates empty `backups/` and `exports/workflows/` directories, a clean inventory,
domain-specific AGENTS/plan files, and a configured but non-secret `.env.example`.

## First actions in the generated project

1. Read `AGENTS.md` and complete `MIGRATION_INVENTORY.md`.
2. Match `N8N_VERSION` to the source installation.
3. Back up and export the source n8n instance.
4. Continue through `DEPLOYMENT_PLAN.md` in order.
