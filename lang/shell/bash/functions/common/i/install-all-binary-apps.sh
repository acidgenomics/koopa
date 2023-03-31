#!/usr/bin/env bash

koopa_install_all_binary_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2023-03-31.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local app_name app_names bool
    koopa_assert_has_no_args "$#"
    declare -A bool
    bool['bootstrap']=0
    if [[ ! -d "$(koopa_app_prefix --allow-missing 'aws-cli')" ]]
    then
        bool['bootstrap']=1
    fi
    readarray -t app_names <<< "$(koopa_shared_apps)"
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install 'aws-cli'
    fi
    for app_name in "${app_names[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        if [[ -d "$prefix" ]]
        then
            koopa_alert_note "'${app_name}' already installed at '${prefix}'."
            continue
        fi
        koopa_cli_install --binary "$app_name"
    done
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install --reinstall 'aws-cli'
    fi
    return 0
}
