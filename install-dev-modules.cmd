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

warden check-env-file

## Install Developer Modules
print_info "Installing Developer Modules..."
warden env exec -T php-fpm composer require --dev markshust/magento2-module-disabletwofactorauth
warden env exec -T php-fpm composer require --dev yireo/magento2-whoops
warden env exec -T php-fpm composer require --dev vpietri/adm-quickdevbar
warden env exec -T php-fpm php bin/magento module:enable MarkShust_DisableTwoFactorAuth Yireo_Whoops ADM_QuickDevBar
warden env exec -T php-fpm php bin/magento setup:upgrade

## output to user
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo "============================================================"
echo -e "${CYAN}Developer Modules Installed${NC}"
echo -e " - markshust/magento2-module-disabletwofactorauth"
echo -e " - yireo/magento2-whoops"
echo -e " - vpietri/adm-quickdevbar"
echo "============================================================"
