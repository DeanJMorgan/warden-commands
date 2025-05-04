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

## Determine the project root directory
PROJECT_ROOT="${WARDEN_ENV_PATH}${WARDEN_WEB_ROOT}"

## Check if n98-magerun2.phar exists in project root
if [ ! -f "${PROJECT_ROOT}/n98-magerun2.phar" ]; then
  print_info "Can't find n98-magerun2.phar, please install by running warden install-magerun... exiting."
  exit 1
fi

## Check if ./.warden/database/${WARDEN_ENV_NAME}.db.sql.gz exists, if it does ask the user if they want to continue
if [ -f ./.warden/database/${WARDEN_ENV_NAME}.db.sql.gz ]; then
  print_info "A database backup already exists for this environment."
  read -p "Would you like to continue and overwrite the existing backup? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Exiting..."
    exit 1
  fi
fi

## Run the database dump
print_info "Database dump started."
warden env exec -T php-fpm php ./n98-magerun2.phar db:dump --compression=gzip --strip="@stripped" --stdout > ${WARDEN_ENV_NAME}.db.sql.gz
sleep 10
print_info "Database dump complete."

## Check for .warden/database directory and create it if it doesn't exist
print_info "Checking for .warden/database directory."
if [ ! -d ./.warden/database ]; then
  mkdir ./.warden/database
fi

## Copy the database dump to the .warden/database directory
print_info "Moving database dump to .warden/database/${WARDEN_ENV_NAME}.db.sql.gz"
mv ${WARDEN_ENV_NAME}.db.sql.gz ./.warden/database/${WARDEN_ENV_NAME}.db.sql.gz

print_info "Database backup complete."
