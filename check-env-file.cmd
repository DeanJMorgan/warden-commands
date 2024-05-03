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

## Check for MAGENTO_PUBLIC_KEY and MAGENTO_PRIVATE_KEY in the .env file
if [[ -z ${MAGENTO_PUBLIC_KEY} || -z ${MAGENTO_PRIVATE_KEY} ]]; then
    print_info "MAGENTO_PUBLIC_KEY and/or MAGENTO_PRIVATE_KEY not set in .env file."
    print_info "Please set these values in the .env file and try again."
    exit 1
fi

## Check for MAGENTO_PACKAGE and MAGENTO_VERSION in the .env file
if [[ -z ${MAGENTO_PACKAGE} || -z ${MAGENTO_VERSION} ]]; then
    print_info "MAGENTO_PACKAGE and/or MAGENTO_VERSION not set in .env file."
    print_info "Please set these values in the .env file and try again."
    exit 1
fi

## Check for MAGENTO_CRYPT_KEY in the .env file
if [[ -z ${MAGENTO_CRYPT_KEY} ]]; then
    print_info "MAGENTO_CRYPT_KEY not set in .env file."
    print_info "Please set this value in the .env file and try again."
    exit 1
fi
