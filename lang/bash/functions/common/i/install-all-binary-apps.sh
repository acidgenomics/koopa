#!/usr/bin/env bash

koopa_install_all_binary_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2023-09-27.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local -A app bool
    local -a app_names
    local app_name
    koopa_assert_has_no_args "$#"
    if ! koopa_can_install_binary
    then
        koopa_stop 'No binary file access.'
    fi
    app['aws']="$(koopa_locate_aws --allow-missing --allow-system)"
    bool['bootstrap']=0
    [[ ! -x "${app['aws']}" ]] && bool['bootstrap']=1
    readarray -t app_names <<< "$(koopa_shared_apps)"
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        koopa_install_aws_cli --no-dependencies
    fi
    for app_name in "${app_names[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        [[ -d "$prefix" ]] && continue
        koopa_cli_install --binary "$app_name"
    done
    if [[ "${bool['bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install --reinstall 'aws-cli'
    fi
    return 0
}
