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

## Set developer configs
print_info "Setting Developer Configs..."
warden env exec -T php-fpm php bin/magento config:set web/seo/use_rewrites 1
warden env exec -T php-fpm php bin/magento config:set system/full_page_cache/caching_application 2
warden env exec -T php-fpm php bin/magento config:set system/full_page_cache/ttl 604800
warden env exec -T php-fpm php bin/magento config:set admin/security/use_form_key 0
warden env exec -T php-fpm php bin/magento config:set admin/security/session_lifetime 31536000
warden env exec -T php-fpm php bin/magento config:set admin/security/password_lifetime 0
warden env exec -T php-fpm php bin/magento config:set admin/security/password_is_forced 0
warden env exec -T php-fpm php bin/magento config:set web/cookie/cookie_lifetime 86400
warden env exec -T php-fpm php bin/magento config:set dev/static/sign 0
warden env exec -T php-fpm php bin/magento config:set dev/template/minify_html 0
warden env exec -T php-fpm php bin/magento config:set dev/js/merge_files 0
warden env exec -T php-fpm php bin/magento config:set dev/js/enable_js_bundling 0
warden env exec -T php-fpm php bin/magento config:set dev/js/minify_files 0
warden env exec -T php-fpm php bin/magento config:set dev/js/move_script_to_bottom 0
warden env exec -T php-fpm php bin/magento config:set dev/css/merge_css_files 0
warden env exec -T php-fpm php bin/magento config:set dev/css/minify_files 0
warden env exec -T php-fpm php bin/magento deploy:mode:set developer

## output to user
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

echo "============================================================"
echo -e "${CYAN}Developer Configs Set${NC}"
echo -e " - web/seo/use_rewrites ${BOLD} admin${NC}"
echo -e " - system/full_page_cache/caching_application ${BOLD} 2${NC}"
echo -e " - system/full_page_cache/ttl ${BOLD} 604800${NC}"
echo -e " - admin/security/use_form_key ${BOLD} 0${NC}"
echo -e " - admin/security/session_lifetime ${BOLD} 31536000${NC}"
echo -e " - admin/security/password_lifetime ${BOLD} 0${NC}"
echo -e " - admin/security/password_is_forced ${BOLD} 0${NC}"
echo -e " - web/cookie/cookie_lifetime ${BOLD} 86400${NC}"
echo -e " - dev/static/sign ${BOLD} 0${NC}"
echo -e " - dev/template/minify_html ${BOLD} 0${NC}"
echo -e " - dev/js/merge_files ${BOLD} 0${NC}"
echo -e " - dev/js/enable_js_bundling ${BOLD} 0${NC}"
echo -e " - dev/js/minify_files ${BOLD} 0${NC}"
echo -e " - dev/js/move_script_to_bottom ${BOLD} 0${NC}"
echo -e " - dev/css/merge_css_files ${BOLD} 0${NC}"
echo -e " - dev/css/minify_files ${BOLD} 0${NC}"
echo -e " - deploy:mode:set ${BOLD} developer${NC}"
echo "============================================================"
