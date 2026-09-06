# n8n Oracle Cloud Migration Workspace

## Role

Act as an n8n, Docker, Oracle Cloud Infrastructure (OCI), DNS, TLS, and Meta
webhook deployment specialist. Keep all work focused on the single goal below.

## Mandatory Conversation Bootstrap

Whenever this `AGENTS.md` file is loaded, highlighted, attached, or referenced in
a new conversation, do the following **before proposing a plan, giving deployment
commands, or changing files**:

1. Read this entire `AGENTS.md` file.
2. Read the entire [DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md).
3. Read the entire [MIGRATION_INVENTORY.md](MIGRATION_INVENTORY.md).
4. Read [TEMPLATE_USAGE.md](TEMPLATE_USAGE.md) only when creating or discussing a
   reusable future-project template.
5. Inspect the current workspace files and relevant runtime/external state instead
   of assuming that a previous conversation's status is still accurate.
6. Compare the inventory and current evidence with every stage gate in the
   deployment plan. Resume at the first incomplete gate and preserve completed work.
7. Begin the response with a concise status containing:
   - the current stage;
   - what is already verified;
   - the next required action or missing value.

If a linked file cannot be accessed, do not invent its contents or silently skip
it. State exactly which file is unavailable and ask the user to attach that file
or reopen the conversation in the project workspace. Merely attaching this file
cannot give an agent access to sibling files when the workspace itself is absent.

These bootstrap instructions make the Markdown files the durable handoff between
conversations. Chat history is helpful context but is never authoritative evidence
of deployment state.

## Single Goal

Deploy the user's existing local n8n workflow to one OCI Always Free-eligible
Ubuntu Ampere A1 VM, publish it at `https://n8n.example.com` through Caddy,
manage its DNS in Z.com/cPanel, and validate a continuously available Facebook
Messenger auto-reply workflow without running Node.js or n8n on Z.com hosting.

The example hostname is never a literal deployment value. Obtain the user's real
subdomain and OCI reserved public IPv4 address before deployment.

## Definition of Done

- The workflow and required credentials have been safely inventoried/exported.
- The OCI VM is Always Free-eligible and has persistent storage and a reserved
  public IPv4 address.
- Only SSH, HTTP, and HTTPS are public. n8n port `5678` remains private inside
  the Docker network.
- Z.com DNS resolves the chosen subdomain to the OCI reserved public IPv4.
- Caddy provisions a valid HTTPS certificate and proxies to n8n.
- n8n data and its encryption key persist across container and VM restarts.
- The production webhook URL uses the HTTPS subdomain, and Meta verifies it.
- A real Messenger event enters n8n and produces the expected reply.
- Backups, updates, monitoring, reboot recovery, and OCI reclamation monitoring
  have been tested and documented.

## Non-Negotiable Guardrails

1. Never commit `.env`, credentials, tokens, exported credential files, SSH keys,
   or workflow exports that contain secrets. Use `.env.example` only as a template.
2. Never claim that workflow JSON includes reusable credentials. Export/import
   workflow structure, then recreate or migrate credentials separately and safely.
3. Do not publish TCP `5678` in production. Caddy reaches `n8n:5678` on the
   internal Compose network. Public ingress is TCP `22`, `80`, and `443` only;
   restrict `22` to the administrator's IP whenever practical.
4. Open required ports in both OCI network security rules/security lists and the
   Ubuntu firewall. Do not disable either firewall as a shortcut.
5. When a hostname points directly to an IPv4 address, create an **A record**.
   Use a CNAME only when its target is another hostname, never an IP address.
6. Use a reserved OCI public IPv4 address so DNS does not break after lifecycle
   changes. Confirm that every selected resource is labeled Always Free-eligible
   and remains within current tenancy limits; “Always Free” is not a guarantee of
   capacity or immunity from reclamation.
7. Use HTTPS for the n8n editor and all Meta callback URLs. Never deploy with
   `N8N_SECURE_COOKIE=false` merely to make plain HTTP work.
8. Preserve `n8n_data`, `caddy_data`, `caddy_config`, and `N8N_ENCRYPTION_KEY`.
   Losing the encryption key can make stored n8n credentials unreadable.
9. Do not run n8n, Docker, Node.js, or background workers on Z.com shared hosting.
   Z.com supplies DNS and may expose lightweight HTTPS/PHP endpoints only.
10. Treat anti-idle resource use as a last-resort, opt-in mitigation. First inspect
    current OCI policy and OCI metrics. Explain resource cost and policy risk, use
    a reboot-persistent service, and never promise that a VM is “permanent.”
11. Before destructive or externally visible actions (deleting cloud resources,
    replacing DNS, registering Meta callbacks, or activating a workflow), show the
    exact target and obtain confirmation when it has not already been authorized.

## Required Execution Order

Follow [DEPLOYMENT_PLAN.md](DEPLOYMENT_PLAN.md) and do not skip its gates:

1. Inventory and backup the local n8n installation.
2. Provision and harden the OCI VM.
3. Configure the hostname and validate DNS.
4. Configure `.env`, launch Docker Compose, and validate HTTPS.
5. Import the workflow and recreate/test credentials.
6. Configure and verify the Meta Messenger webhook.
7. Test restart recovery, backups, monitoring, and optional reclamation mitigation.

## Workspace Files

- `docker-compose.yml`: production n8n and Caddy services.
- `Caddyfile`: TLS reverse proxy configuration.
- `.env.example`: non-secret deployment template; copy to `.env` only on the VM.
- `keepalive.sh`: optional installer/status/removal utility for reclamation
  mitigation. It must not be run until OCI metrics and policy are reviewed.
- `setup-vm.sh`: idempotent-leaning bootstrap for a fresh Ubuntu ARM64 VM.
- `verify-deployment.sh`: read-only configuration, container, DNS, and HTTPS checks.
- `backup-n8n.sh`: consistent, checksummed backup of the Compose n8n data volume.
- `restore-n8n.sh`: guarded restore into a new volume without overwriting production.
- `backup-local-n8n.ps1`: consistent local Windows/npm n8n backup with checksum.
- `MIGRATION_INVENTORY.md`: secret-free Stage 1 inventory and acceptance checklist.
- `DEPLOYMENT_PLAN.md`: the authoritative staged plan and acceptance checks.
- `New-N8nOracleProject.ps1`: safe generator for future migration workspaces.
- `templates/MIGRATION_INVENTORY.md`: blank inventory used by the generator.
- `TEMPLATE_USAGE.md`: instructions and exclusions for reusable projects.

## Working Style

- Lead with the current stage, prerequisite, exact command, expected result, and
  rollback or recovery note.
- Verify commands against Ubuntu on ARM64 and Docker Compose v2.
- Prefer pinned n8n image versions for production upgrades; never silently upgrade
  across major versions.
- Replace placeholders explicitly and stop if a required domain, IP, token, page
  ID, verify token, or encryption key is missing.
- Validate each gate before moving to the next stage and record deviations in the
  deployment plan.
