# Migration Inventory

Complete this file without entering passwords, access tokens, app secrets,
encryption keys, private keys, or credential values. Store secret material in a
password manager or encrypted backup and reference only its location/label here.

## Local n8n source

- Installation type (Docker/npm/Desktop/other): `Global npm installation`
- n8n version: `2.22.6`
- Node.js/npm versions: `Node.js 22.16.0 / npm 10.9.2`
- Operating system: `Windows`
- Local data location or Docker volume: `C:\Users\chaze\.n8n`
- Encryption-key backup label/location: `Contained in private local source ZIP; off-device encrypted copy still required`
- Database (SQLite/PostgreSQL): `SQLite`
- Approximate database size: `3,317,760 bytes main DB; WAL present`
- Local source backup: `backups/local-n8n-20260905T180103Z.zip` (private and Git-ignored)
- Local source backup SHA-256: `a4769c5da65d71e49b7c7044fc701f5341e47ce766068e79bf0940e192766c8f`
- Community nodes and versions:

  | Package | Version | Used by workflow |
  |---|---:|---|
  | | | |

## Workflow export

- Workflow name: `____________________________________________________________`
- Workflow ID (reference only): `_____________________________________________`
- Export date/time: `_________________________________________________________`
- Exported JSON secure-storage location: `____________________________________`
- Export checksum (SHA-256): `________________________________________________`
- Export status: `Pending manual UI export; CLI export on Windows 2.22.6 hung and created no files`
- Current production webhook path(s), without hostname:

  | Node | Path | HTTP method | Test/production |
  |---|---|---|---|
  | | | | |

- Environment-variable names used (names only):

  | Variable name | Purpose | Secret-store label |
  |---|---|---|
  | | | |

- External files or mounted paths:

  | Path | Purpose | Migration destination |
  |---|---|---|
  | | | |

## Credentials inventory

Do not paste credential values here.

| n8n credential name | Type | Used by node(s) | Recreate or migrate | Secret-store label |
|---|---|---|---|---|
| | | | | |

## Meta Messenger application

- Meta app name: `____________________________________________________________`
- App ID (not the app secret): `______________________________________________`
- Facebook Page name: `_______________________________________________________`
- Page ID: `_________________________________________________________________`
- App mode (Development/Live): `______________________________________________`
- Required webhook fields: `__________________________________________________`
- Required permissions/features: `___________________________________________`
- Verify-token secret-store label: `_________________________________________`
- Page-token secret-store label: `___________________________________________`
- Existing callback URL (redact sensitive path if necessary): `______________`

## Target infrastructure

- OCI tenancy/home region: `__________________________________________________`
- Availability domain: `______________________________________________________`
- VM display name: `__________________________________________________________`
- Image and version: `________________________________________________________`
- Shape/OCPUs/RAM: `__________________________________________________________`
- Reserved public IPv4: `_____________________________________________________`
- Administrator CIDR allowed for SSH: `______________________________________`
- Z.com domain: `_____________________________________________________________`
- Selected n8n hostname: `____________________________________________________`
- DNS TTL: `_________________________________________________________________`
- ACME contact email: `_______________________________________________________`
- Target n8n version: `_______________________________________________________`

## Stage 1 acceptance checklist

- [x] Local n8n version is recorded.
- [x] Database/data-directory backup exists and has a SHA-256 checksum.
- [ ] The encryption key has an encrypted off-device backup.
- [ ] Workflow JSON is exported and its checksum recorded.
- [ ] Community-node dependencies are listed.
- [ ] Credential names/types and secret-store references are listed.
- [ ] Webhook paths, variable names, and external files are listed.
- [ ] A restore test has been performed on disposable storage.
