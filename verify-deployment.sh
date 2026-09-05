#!/usr/bin/env bash
set -Eeuo pipefail

# Read-only deployment checks. Run from the directory containing docker-compose.yml.

failures=0

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; failures=$((failures + 1)); }

for command_name in docker curl getent; do
  command -v "${command_name}" >/dev/null 2>&1 \
    && pass "${command_name} is installed" \
    || fail "${command_name} is required"
done

if [[ ! -f .env ]]; then
  fail ".env exists"
else
  pass ".env exists"
  read_env() {
    sed -n "s/^${1}=//p" .env | tail -n 1 | tr -d '\r'
  }
  N8N_DOMAIN="$(read_env N8N_DOMAIN)"
  ACME_EMAIL="$(read_env ACME_EMAIL)"
  N8N_VERSION="$(read_env N8N_VERSION)"
  N8N_ENCRYPTION_KEY="$(read_env N8N_ENCRYPTION_KEY)"

  [[ "${N8N_DOMAIN:-}" =~ ^[A-Za-z0-9]([A-Za-z0-9.-]*[A-Za-z0-9])?$ ]] \
    && [[ "${N8N_DOMAIN}" == *.* ]] \
    && [[ "${N8N_DOMAIN}" != "n8n.example.com" ]] \
    && pass "N8N_DOMAIN is a non-placeholder hostname" \
    || fail "N8N_DOMAIN is missing, malformed, or still a placeholder"

  [[ -n "${ACME_EMAIL:-}" && "${ACME_EMAIL}" == *@*.* && "${ACME_EMAIL}" != "admin@example.com" ]] \
    && pass "ACME_EMAIL is set" \
    || fail "ACME_EMAIL is missing, malformed, or still a placeholder"

  [[ -n "${N8N_VERSION:-}" && "${N8N_VERSION}" != "latest" ]] \
    && pass "N8N_VERSION is pinned" \
    || fail "N8N_VERSION must be pinned and cannot be latest"

  [[ -n "${N8N_ENCRYPTION_KEY:-}" && "${#N8N_ENCRYPTION_KEY}" -ge 32 \
    && "${N8N_ENCRYPTION_KEY}" != replace-* ]] \
    && pass "N8N_ENCRYPTION_KEY is non-placeholder and at least 32 characters" \
    || fail "N8N_ENCRYPTION_KEY is missing, too short, or still a placeholder"
fi

if command -v docker >/dev/null 2>&1; then
  docker compose config --quiet \
    && pass "Compose configuration is valid" \
    || fail "Compose configuration is invalid"

  if docker compose ps --status running --services 2>/dev/null | grep -qx n8n \
    && docker compose ps --status running --services 2>/dev/null | grep -qx caddy; then
    pass "n8n and Caddy containers are running"
  else
    fail "n8n and Caddy containers are not both running"
  fi

  published_port="$(docker compose port n8n 5678 2>/dev/null || true)"
  if [[ -n "${published_port}" ]]; then
    fail "n8n port 5678 is published on the host"
  else
    pass "n8n port 5678 is not published on the host"
  fi
fi

if [[ -n "${N8N_DOMAIN:-}" ]]; then
  resolved_ipv4="$(getent ahostsv4 "${N8N_DOMAIN}" 2>/dev/null | awk 'NR == 1 {print $1}')"
  [[ -n "${resolved_ipv4}" ]] \
    && pass "${N8N_DOMAIN} resolves to ${resolved_ipv4}" \
    || fail "${N8N_DOMAIN} has no public IPv4 resolution"

  if [[ -n "${EXPECTED_IPV4:-}" ]]; then
    [[ "${resolved_ipv4}" == "${EXPECTED_IPV4}" ]] \
      && pass "DNS matches EXPECTED_IPV4" \
      || fail "DNS ${resolved_ipv4:-none} does not match EXPECTED_IPV4 ${EXPECTED_IPV4}"
  fi

  curl --fail --silent --show-error --head --max-time 20 \
    "https://${N8N_DOMAIN}" >/dev/null \
    && pass "HTTPS endpoint responds successfully" \
    || fail "HTTPS endpoint is not responding successfully"
fi

if (( failures > 0 )); then
  printf '\nVerification finished with %d failure(s).\n' "${failures}" >&2
  exit 1
fi

printf '\nAll deployment checks passed.\n'
