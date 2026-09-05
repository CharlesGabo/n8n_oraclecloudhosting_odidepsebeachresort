# Migration Inventory

Never enter passwords, access tokens, app secrets, encryption keys, private keys,
or credential values here. Record only password-manager or encrypted-backup labels.

## Local n8n source

- Installation type: `_______________________________________________________`
- n8n version: `_____________________________________________________________`
- Node.js/npm versions, if applicable: `_____________________________________`
- Operating system: `________________________________________________________`
- Local data location or Docker volume: `____________________________________`
- Encryption-key secure-backup label: `______________________________________`
- Database and approximate size: `___________________________________________`

### Community nodes

| Package | Version | Used by workflow |
|---|---:|---|
| | | |

## Workflow export

- Workflow name and ID: `____________________________________________________`
- Export date/time: `_________________________________________________________`
- Secure-storage location: `_________________________________________________`
- SHA-256: `_________________________________________________________________`

| Webhook node | Path only | HTTP method | Test/production |
|---|---|---|---|
| | | | |

| Environment-variable name | Purpose | Secret-store label |
|---|---|---|
| | | |

| External file/path | Purpose | Migration destination |
|---|---|---|
| | | |

## Credentials

| n8n credential name | Type | Used by nodes | Recreate/migrate | Secret-store label |
|---|---|---|---|---|
| | | | | |

## Meta Messenger

- Meta app name and ID: `____________________________________________________`
- Facebook Page name and ID: `_______________________________________________`
- App mode: `________________________________________________________________`
- Required webhook fields: `_________________________________________________`
- Required permissions/features: `___________________________________________`
- Verify-token secret-store label: `_________________________________________`
- Page-token secret-store label: `___________________________________________`
- Existing callback URL: `___________________________________________________`

## OCI and DNS target

- OCI tenancy/home region: `__________________________________________________`
- Availability domain: `______________________________________________________`
- VM name/image/shape/OCPUs/RAM: `___________________________________________`
- Reserved public IPv4: `_____________________________________________________`
- Administrator SSH CIDR: `__________________________________________________`
- Z.com domain and selected n8n hostname: `___________________________________`
- DNS TTL: `_________________________________________________________________`
- ACME contact email: `_______________________________________________________`
- Target n8n version: `_______________________________________________________`

## Stage 1 acceptance

- [ ] Source version and installation are recorded.
- [ ] Checksummed data backup exists.
- [ ] Encryption key has an encrypted off-device backup.
- [ ] Checksummed workflow JSON is exported.
- [ ] Community nodes, credentials, variables, and files are inventoried.
- [ ] A restore test has passed on disposable storage.
