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

print_info "Initialising ${WARDEN_ENV_NAME}..."

## setup SSL if not already done so
print_info "Setting up SSL for ${TRAEFIK_DOMAIN}..."
if [[ ! -f ~/.den/ssl/certs/${TRAEFIK_DOMAIN}.crt.pem ]]; then
    print_info "Setting up SSL for ${TRAEFIK_DOMAIN}..."
    warden sign-certificate "${TRAEFIK_DOMAIN}"
fi

## Check for flag in command with value of clean-install and set variable
while (( "$#" )); do
    case "$1" in
        --clean-install)
            CLEAN_INSTALL=1
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if [[ ${CLEAN_INSTALL:-0} -eq 1 ]]; then
## if clean install flag is set, run magento-install
    warden install-magento
else
## else import env.php and database if they exist
    ## check for app/etc/env.php
    print_info "Check for app/etc/env.php..."
    if [[ ! -f app/etc/env.php ]]; then
        if [[ -f app/etc/env.warden.php ]]; then
            print_info "Copying app/etc/env.warden.php to app/etc/env.php..."
            cp app/etc/env.warden.php app/etc/env.php
        else
            print_info "Downloading default warden env.php and saving to app/etc/env.php..."
            ## Download default warden env.php and save to app/etc/env.php
            curl -s -o app/etc/env.php https://gist.githubusercontent.com/DeanJMorgan/03e77c5a8785ac7e08241bfea6e8fe87/raw/e98b7f58c68347b7b57b6a6d990eed6bc6f1a981/env.warden.php
        fi

        ## replace MAGENTO_CRYPT_KEY with the one from .env
        sed -i'' -e "s/MAGENTO_CRYPT_KEY/${MAGENTO_CRYPT_KEY}/g" app/etc/env.php
    fi

    warden database-restore
fi

warden shell -c "mkdir -p pub/static"

## Install magerun2
print_info "Installing magerun2..."
warden install-magerun

## Run composer install
print_info "Running composer install..."
warden shell -c "composer install"

## Set the store urls
warden config-set-store-urls

## Set developer configs
warden config-set-developer

## Install developer modules
warden install-dev-modules

print_info "Finalising setup..."
## Run setup:upgrade
warden env exec -T php-fpm php bin/magento setup:upgrade

## Run indexer:reindex
warden env exec -T php-fpm php bin/magento indexer:reindex

## Create admin user
warden create-admin-user

## Set the store URL
STORE_URL="https://${TRAEFIK_DOMAIN}/"
BACKEND_URL="${STORE_URL}${ADMIN_PATH}"

## output to user
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo "============================================================"
echo -e "Site is running at: ${CYAN}${STORE_URL}${NC}"
echo -e "Admin is running at: ${CYAN}${BACKEND_URL}${NC}"
echo -e "${BOLD} - Admin User:${NC} admin"
echo -e "${BOLD} - Admin Password:${NC} admin!234567890"
echo "============================================================"
print_info "${WARDEN_ENV_NAME} initialisation complete."
