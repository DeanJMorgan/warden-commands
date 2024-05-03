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

## Check if n98-magerun2.phar exists
if [ ! -f ./n98-magerun2.phar ]; then
## Install n98-magerun2.phar
  print_info "Installing magerun..."
  warden shell -c "curl -sS -O https://files.magerun.net/n98-magerun2.phar"
  warden shell -c "curl -sS -o n98-magerun2.phar.sha256 https://files.magerun.net/sha256.php?file=n98-magerun2.phar"
  warden shell -c "shasum -a 256 -c n98-magerun2.phar.sha256"
  warden shell -c "chmod +x ./n98-magerun2.phar"
  warden shell -c "./n98-magerun2.phar --version"
else
## Update n98-magerun2.phar
  print_info "n98-magerun2.phar already exists... updating to latest version."
  warden shell -c "./n98-magerun2.phar self-update"
fi

## output to user
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo "============================================================"
echo -e "${CYAN}n98-Magerun2 Installed${NC}"
echo -e " - Run ${BOLD}./n98-magerun2.phar${NC} to use"
echo "============================================================"
