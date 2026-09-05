#!/usr/bin/env bash
set -Eeuo pipefail

# Back up this Compose project's n8n volume without embedding .env in the archive.
# For a consistent SQLite backup, n8n is stopped briefly and restarted afterward.

PROJECT_NAME="${COMPOSE_PROJECT_NAME:-n8n-oracle}"
VOLUME_NAME="${N8N_VOLUME_NAME:-${PROJECT_NAME}_n8n_data}"
BACKUP_DIR="${BACKUP_DIR:-./backups}"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
archive_name="n8n-data-${timestamp}.tar.gz"
archive_path="${BACKUP_DIR}/${archive_name}"
was_running="false"

command -v docker >/dev/null 2>&1 || { echo "Docker is required." >&2; exit 1; }
docker volume inspect "${VOLUME_NAME}" >/dev/null
mkdir -p -- "${BACKUP_DIR}"
chmod 700 "${BACKUP_DIR}"

if docker compose ps --status running --services 2>/dev/null | grep -qx n8n; then
  was_running="true"
  docker compose stop n8n
fi

restart_n8n() {
  if [[ "${was_running}" == "true" ]]; then
    docker compose start n8n >/dev/null
  fi
}
trap restart_n8n EXIT

docker run --rm \
  --mount "type=volume,src=${VOLUME_NAME},dst=/source,readonly" \
  --mount "type=bind,src=$(cd "${BACKUP_DIR}" && pwd),dst=/backup" \
  alpine:3.22 tar -C /source -czf "/backup/${archive_name}" .

chmod 600 "${archive_path}"
sha256sum "${archive_path}" | tee "${archive_path}.sha256"

echo
echo "Backup created: ${archive_path}"
echo "It may contain credentials and personal data. Encrypt it and copy it off-VM."
echo "Back up N8N_ENCRYPTION_KEY separately; .env was intentionally excluded."
