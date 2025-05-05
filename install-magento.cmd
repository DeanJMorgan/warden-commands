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

print_info "Starting Magento Install..."

## Set the store URL
STORE_URL="https://${TRAEFIK_DOMAIN}/"
BACKEND_URL="${STORE_URL}${ADMIN_PATH}"

## Configure composer auth
warden env exec -T php-fpm composer config --global http-basic.repo.magento.com "${MAGENTO_PUBLIC_KEY}" "${MAGENTO_PRIVATE_KEY}"

## Run composer create-project and copy files to /var/www/html
warden env exec -T php-fpm composer create-project --repository-url=https://repo.magento.com/ \
    "${MAGENTO_PACKAGE}" /tmp/"${WARDEN_ENV_NAME}" "${MAGENTO_VERSION}"
warden shell -c "rsync -a /tmp/${WARDEN_ENV_NAME}/ /var/www/html/"
warden shell -c "rm -rf /tmp/${WARDEN_ENV_NAME}/"

## Install Magento2
warden env exec -T php-fpm php bin/magento setup:install \
    --backend-frontname="${ADMIN_PATH}" \
    --amqp-host=rabbitmq \
    --amqp-port=5672 \
    --amqp-user=guest \
    --amqp-password=guest \
    --db-host=db \
    --db-name=magento \
    --db-user=magento \
    --db-password=magento \
    --language=en_GB \
    --currency=GBP \
    --timezone=Europe/London \
    --search-engine=opensearch \
    --opensearch-host=opensearch \
    --opensearch-port=9200 \
    --opensearch-index-prefix=magento2 \
    --opensearch-enable-auth=0 \
    --opensearch-timeout=15 \
    --http-cache-hosts=varnish:80 \
    --session-save=redis \
    --session-save-redis-host=redis \
    --session-save-redis-port=6379 \
    --session-save-redis-db=2 \
    --session-save-redis-max-concurrency=20 \
    --cache-backend=redis \
    --cache-backend-redis-server=redis \
    --cache-backend-redis-db=0 \
    --cache-backend-redis-port=6379 \
    --page-cache=redis \
    --page-cache-redis-server=redis \
    --page-cache-redis-db=1 \
    --page-cache-redis-port=6379 \
    --cleanup-database

## Update secure and unsecure base urls
warden env exec -T php-fpm php bin/magento config:set web/unsecure/base_url \
    "https://${TRAEFIK_DOMAIN}/"
warden env exec -T php-fpm php bin/magento config:set web/secure/base_url \
    "https://${TRAEFIK_DOMAIN}/"

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
print_info "Magento 2 installation complete."
