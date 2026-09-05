# n8n OCI + Z.com Migration Plan

## Goal and current boundary

The single goal and definition of done are in `AGENTS.md`. This plan prepares the
infrastructure first; building or activating the Messenger automation begins only
after the platform passes Stages 1–4.

Record the real values before deployment:

- n8n hostname: `____________________________`
- OCI home region: `_________________________`
- OCI reserved public IPv4: `________________`
- administrator public IPv4/CIDR: `__________`
- pinned n8n version matching local: `_______`

Use `MIGRATION_INVENTORY.md` as the authoritative record for these values and all
Stage 1 dependencies. Never enter secret values in that file.

## Stage 1 — Inventory and export local n8n

1. Record the local n8n version and installed community nodes.
2. Back up the local `.n8n` directory/database and encryption key if available.
3. In each workflow canvas, use the top-right menu and download the workflow JSON.
4. Inventory credentials, environment variables, webhook paths, Meta app/page IDs,
   and external files. Do not store their secret values in this repository.
5. Keep exports in encrypted storage; workflow JSON can contain sensitive values.
6. For a Compose-based local instance compatible with this workspace, create a
   consistent data-volume backup and test it in a new disposable volume:

   ```bash
   chmod +x backup-n8n.sh restore-n8n.sh
   ./backup-n8n.sh
   CONFIRM_RESTORE=CREATE_NEW_VOLUME \
     RESTORE_VOLUME_NAME=n8n_restore_test \
     ./restore-n8n.sh backups/n8n-data-YYYYMMDDTHHMMSSZ.tar.gz
   ```

   These scripts never include `.env`; preserve `N8N_ENCRYPTION_KEY` separately.
7. For the detected Windows/npm source installation, stop n8n and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\backup-local-n8n.ps1
   ```

   The resulting ignored ZIP contains sensitive database and encryption material.
   Keep it private and encrypt it before copying it off the workstation.

Gate: backup restoration information, workflow JSON, dependencies, and credential
inventory are available before any cloud changes.

## Stage 2 — Provision and harden OCI

1. In the OCI home region, create an Always Free-eligible Ubuntu ARM64
   `VM.Standard.A1.Flex` instance within the current free limits.
2. Use a public subnet, SSH key authentication, and a reserved public IPv4.
3. OCI ingress rules: TCP 22 from the administrator CIDR; TCP 80 and 443 from
   `0.0.0.0/0`. Add IPv6 rules only if IPv6 is deliberately configured. Do not add
   public TCP 5678. UDP 443 is optional for HTTP/3 and may be omitted.
4. In this repository directory, run the bootstrap with the administrator's real
   public CIDR. It installs Docker Engine and Compose from Docker's supported
   repository, enables security updates, and configures the Ubuntu firewall:

   ```bash
   chmod +x setup-vm.sh verify-deployment.sh keepalive.sh
   ADMIN_CIDR=203.0.113.10/32 sudo -E ./setup-vm.sh
   ```
5. Configure UFW only after allowing SSH:

   ```bash
   sudo ufw allow OpenSSH
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   sudo ufw status verbose
   ```

Gate: SSH reconnect succeeds, the reserved IP is attached, and both firewall
layers expose 22/80/443 but not 5678.

## Stage 3 — Configure Z.com DNS

1. Choose a dedicated hostname such as `n8n.example.com`.
2. In cPanel, open **Zone Editor → Manage → Add Record**.
3. Create an **A record** for `n8n` pointing to the OCI reserved IPv4. Remove only
   conflicting records for that exact hostname. A CNAME is appropriate only if
   its destination is another hostname.
4. Wait for DNS propagation and verify from a separate network:

   ```bash
   dig +short n8n.example.com A
   ```

Gate: public DNS returns exactly the reserved OCI IPv4.

## Stage 4 — Launch the secured n8n platform

1. Copy this repository's deployment files to a dedicated VM directory.
2. Copy `.env.example` to `.env`; set the real hostname/email, pin the same n8n
   version used locally, and generate `N8N_ENCRYPTION_KEY` with
   `openssl rand -hex 32`. Back up the key outside the VM.
3. Validate and start:

   ```bash
   docker compose config --quiet
   docker compose pull
   docker compose up -d
   docker compose ps
   docker compose logs --tail=100 caddy n8n
   curl -I https://n8n.example.com
   EXPECTED_IPV4=203.0.113.20 ./verify-deployment.sh
   ```

4. Create the n8n owner account immediately. Do not expose port 5678 as a
   troubleshooting shortcut.

Gate: HTTPS has a trusted certificate, HTTP redirects to HTTPS, the editor loads,
and all containers recover after `sudo reboot`.

## Stage 5 — Import and validate n8n

1. Import the workflow JSON through the n8n UI.
2. Reinstall compatible community nodes, if any.
3. Recreate credentials in n8n; never paste them into workflow JSON or Git.
4. Update environment-dependent URLs and run with test data while inactive.
5. Export a post-migration backup and test a restore procedure.

Gate: every node executes successfully with test data and no secret appears in
logs or repository files.

## Stage 6 — Connect Meta Messenger

1. Use the n8n production webhook URL under `https://<hostname>/webhook/...`.
2. In the Meta app, set the callback URL and matching verify token, complete
   verification, subscribe the intended Page and required messaging fields, and
   use the least permissions required by the current Meta review rules.
3. Activate the workflow only after the test URL is no longer being used.
4. Send a real message from a non-admin test account and correlate Meta delivery,
   n8n execution, and reply results.

Gate: one end-to-end message receives exactly one correct reply, failures are
visible, and retries do not cause duplicate replies.

## Stage 7 — Operations and free-tier monitoring

1. Schedule encrypted off-VM backups of n8n data and the encryption key; test
   restoration. Review disk usage and prune old executions.
2. Monitor container health, HTTPS expiry, CPU, memory, network, disk, and OCI
   announcements/limits. Apply n8n upgrades deliberately after backup.
3. Review OCI's current seven-day idle criteria and actual metrics. Only if the VM
   is at reclamation risk and the account terms permit it, explicitly opt in with:

   ```bash
   chmod +x keepalive.sh
   sudo ./keepalive.sh install
   ```

   Check OCI metrics after 24 hours. Roll back with
   `sudo ./keepalive.sh remove` if resource pressure affects the workload.

Gate: backup restore and reboot recovery pass, monitoring alerts are received, and
the operating procedure names who handles failures and updates.
