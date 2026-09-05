#!/usr/bin/env bash
set -Eeuo pipefail

# Bootstrap a fresh Ubuntu OCI VM. This does not change OCI security rules or DNS.
# Required example:
#   ADMIN_CIDR=203.0.113.10/32 sudo -E ./setup-vm.sh

ADMIN_CIDR="${ADMIN_CIDR:-}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run with sudo and preserve ADMIN_CIDR using sudo -E." >&2
  exit 1
fi

if [[ -z "${ADMIN_CIDR}" ]]; then
  echo "ADMIN_CIDR is required to avoid opening SSH to the world." >&2
  echo "Example: ADMIN_CIDR=203.0.113.10/32 sudo -E ./setup-vm.sh" >&2
  exit 1
fi

if [[ "$(dpkg --print-architecture)" != "arm64" ]]; then
  echo "Warning: expected OCI Ampere ARM64, found $(dpkg --print-architecture)." >&2
fi

. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then
  echo "This script supports Ubuntu only; found ${ID:-unknown}." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get upgrade -y
apt-get install -y ca-certificates curl dnsutils jq ufw unattended-upgrades

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

# Only Caddy publishes container ports. Port 5678 is deliberately absent.
ufw allow from "${ADMIN_CIDR}" to any port 22 proto tcp comment 'restricted SSH'
ufw allow 80/tcp comment 'Caddy HTTP and ACME'
ufw allow 443/tcp comment 'Caddy HTTPS'
ufw --force enable

docker version
docker compose version
ufw status verbose

echo
echo "VM bootstrap complete. Confirm matching OCI ingress rules before continuing."
echo "Log out and reconnect over SSH before changing any firewall rule."
