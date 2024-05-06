#!/usr/bin/env bash
[[ ! ${WARDEN_DIR} ]] && >&2 echo -e "\033[31mThis script is not intended to be run directly!\033[0m" && exit 1
set -euo pipefail

function print_info {
  CYAN='\033[0;36m'
  NC='\033[0m'
  echo -e "### [$(date +%H:%M:%S)] ${CYAN}$@${NC}"
}

## load configuration needed for setup
WARDEN_ENV_PATH="$(locateEnvPath)" || exit $?
loadEnvConfig "${WARDEN_ENV_PATH}" || exit $?

assertDockerRunning

## change into the project directory
cd "${WARDEN_ENV_PATH}"

## Re-source .env to load in custom variables
source .env

## Set the store URL
STORE_URL="https://${TRAEFIK_DOMAIN}/"
BACKEND_URL="${STORE_URL}${ADMIN_PATH}"

## Update store urls
warden env exec -T php-fpm php bin/magento config:set web/unsecure/base_url \
    "${STORE_URL}"
warden env exec -T php-fpm php bin/magento config:set web/secure/base_url \
    "${STORE_URL}"

print_info "Store URLs updated to ${STORE_URL}"
