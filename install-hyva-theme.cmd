#!/usr/bin/env bash
[[ ! ${WARDEN_DIR} ]] && >&2 echo -e "\033[31mThis script is not intended to be run directly!\033[0m" && exit 1
set -euo pipefail

# Parse command line arguments
INCLUDE_CHECKOUT=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --inc-hyva-checkout)
      INCLUDE_CHECKOUT=1
      shift
      ;;
    *)
      shift
      ;;
  esac
done

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

## Configure Hyva Repository
print_info "Configuring Hyva Repository..."
warden env exec -T php-fpm composer config --auth http-basic.hyva-themes.repo.packagist.com token "${HYVA_LICENSE_KEY}"
warden env exec -T php-fpm composer config repositories.private-packagist composer https://hyva-themes.repo.packagist.com/"${HYVA_PROJECT_NAME}"/

## Install Hyva Modules
print_info "Installing Hyva Modules..."
warden env exec -T php-fpm composer require hyva-themes/magento2-default-theme
warden env exec -T php-fpm composer require hyva-themes/hyva-ui
warden env exec -T php-fpm composer require hyva-themes/magento2-hyva-widgets
warden env exec -T php-fpm composer require hyva-themes/magento2-heroicons2
warden env exec -T php-fpm composer require hyva-themes/magento2-payment-icons

if [ "$INCLUDE_CHECKOUT" -eq 1 ]; then
    print_info "Installing Hyva Checkout..."
    warden env exec -T php-fpm composer require hyva-themes/magento2-hyva-checkout
fi

warden env exec -T php-fpm bin/magento setup:upgrade
print_info "Hyva Modules Installed..."

print_info "Looking for Hyva theme ID..."
## Get theme_id from database for hyva/default theme
THEME_ID=$(warden env exec -T db mysql -u magento -pmagento -N -e "SELECT theme_id FROM theme WHERE theme_path='Hyva/default'" magento)

if [ -z "$THEME_ID" ]; then
    print_info "Could not find Hyva theme ID in the database. Make sure Hyva theme is installed."
    exit 1
fi

print_info "Found Hyva theme ID: ${THEME_ID}"

## Set the theme as default
print_info "Setting Hyva as default theme..."
warden env exec -T php-fpm php bin/magento config:set design/theme/theme_id "${THEME_ID}"

## output to user
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo "============================================================"
echo -e "${CYAN}Hyva Theme Set as Default${NC}"
echo -e "${BOLD} - Theme ID:${NC} ${THEME_ID}"
echo "============================================================"