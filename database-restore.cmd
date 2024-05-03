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

## Check if database backup exists and restore it
if [ -f ./.warden/database/${WARDEN_ENV_NAME}.db.sql.gz ]; then
  print_info "Restoring database..."
  pv ./.warden/database/${WARDEN_ENV_NAME}.db.sql.gz | gunzip | warden db import
else
  print_info "No database backup exists for this environment."
  exit 1
fi
