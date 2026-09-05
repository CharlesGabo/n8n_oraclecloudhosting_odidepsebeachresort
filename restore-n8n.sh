#!/usr/bin/env bash
set -Eeuo pipefail

# Restore into a NEW Docker volume. Existing n8n data is never overwritten.
# Example:
#   CONFIRM_RESTORE=CREATE_NEW_VOLUME ./restore-n8n.sh backups/file.tar.gz

archive_path="${1:-}"
target_volume="${RESTORE_VOLUME_NAME:-n8n_restore_test}"

if [[ "${CONFIRM_RESTORE:-}" != "CREATE_NEW_VOLUME" ]]; then
  echo "Set CONFIRM_RESTORE=CREATE_NEW_VOLUME to acknowledge volume creation." >&2
  exit 2
fi

if [[ -z "${archive_path}" || ! -f "${archive_path}" ]]; then
  echo "Usage: CONFIRM_RESTORE=CREATE_NEW_VOLUME $0 <backup.tar.gz>" >&2
  exit 2
fi

command -v docker >/dev/null 2>&1 || { echo "Docker is required." >&2; exit 1; }

if docker volume inspect "${target_volume}" >/dev/null 2>&1; then
  echo "Refusing to use existing volume: ${target_volume}" >&2
  exit 1
fi

checksum_file="${archive_path}.sha256"
if [[ -f "${checksum_file}" ]]; then
  sha256sum --check "${checksum_file}"
else
  echo "Warning: no checksum file found at ${checksum_file}." >&2
fi

archive_dir="$(cd "$(dirname "${archive_path}")" && pwd)"
archive_name="$(basename "${archive_path}")"
docker volume create "${target_volume}" >/dev/null

cleanup_failed_restore() {
  if [[ "$?" -ne 0 ]]; then
    echo "Restore failed. New volume retained for inspection: ${target_volume}" >&2
  fi
}
trap cleanup_failed_restore EXIT

docker run --rm \
  --mount "type=volume,src=${target_volume},dst=/restore" \
  --mount "type=bind,src=${archive_dir},dst=/backup,readonly" \
  alpine:3.22 tar -C /restore -xzf "/backup/${archive_name}"

echo "Restore completed in new volume: ${target_volume}"
echo "No running Compose service was changed. Test this volume separately."
