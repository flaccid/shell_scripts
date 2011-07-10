#!/bin/sh -e

# rs-describe-deployments.sh

if [ "$2" = 'settings' ]; then
    settings="/?server_settings=true"
fi

. "$HOME/.rightscale/rs_api_config.sh"
. "$HOME/.rightscale/rs_api_creds.sh"

# get XML from API
url="https://my.rightscale.com/api/acct/$rs_api_account_id/deployments$settings"
echo "GET: $url"
deployments_xml=$(curl -s -H "X_API_VERSION: $rs_api_version" -b "$rs_api_cookie" "$url")

# print response from API
echo "$deployments_xml"