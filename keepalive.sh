#!/usr/bin/env bash
set -Eeuo pipefail

# Optional OCI Always Free A1 reclamation mitigation. Review current OCI policy
# and seven-day metrics before enabling this reboot-persistent service.

SERVICE_NAME="oci-a1-memory-reserve.service"
SERVICE_PATH="/etc/systemd/system/${SERVICE_NAME}"
MEMORY_PERCENT="${MEMORY_PERCENT:-22}"

usage() {
  echo "Usage: sudo ./keepalive.sh install|status|remove"
  echo "Optional: MEMORY_PERCENT=22 sudo -E ./keepalive.sh install"
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    echo "Run this command with sudo." >&2
    exit 1
  fi
}

validate_percent() {
  if ! [[ "${MEMORY_PERCENT}" =~ ^[0-9]+$ ]] ||
     (( MEMORY_PERCENT < 21 || MEMORY_PERCENT > 30 )); then
    echo "MEMORY_PERCENT must be an integer from 21 through 30." >&2
    exit 1
  fi
}

install_service() {
  require_root
  validate_percent
  apt-get update
  apt-get install -y stress-ng

  cat >"${SERVICE_PATH}" <<EOF
[Unit]
Description=Optional OCI A1 memory utilization reserve
After=network-online.target
Documentation=https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm

[Service]
Type=simple
ExecStart=/usr/bin/stress-ng --vm 1 --vm-bytes ${MEMORY_PERCENT}% --vm-keep --vm-method zero --timeout 0
Restart=always
RestartSec=10
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now "${SERVICE_NAME}"
  systemctl --no-pager --full status "${SERVICE_NAME}"
  echo "Review OCI MemoryUtilization over the next 24 hours; disable if it harms n8n."
}

remove_service() {
  require_root
  systemctl disable --now "${SERVICE_NAME}" 2>/dev/null || true
  rm -f -- "${SERVICE_PATH}"
  systemctl daemon-reload
  echo "Removed ${SERVICE_NAME}; the stress-ng package was left installed."
}

case "${1:-}" in
  install) install_service ;;
  status) systemctl --no-pager --full status "${SERVICE_NAME}" ;;
  remove) remove_service ;;
  *) usage; exit 2 ;;
esac
