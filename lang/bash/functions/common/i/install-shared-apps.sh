#!/usr/bin/env bash

koopa_install_shared_apps() {
    # """
    # Build and install multiple shared apps from source.
    # @note Updated 2025-03-08.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local -A app bool dict
    local -a app_names
    local app_name
    koopa_assert_is_owner
    bool['all']=0
    bool['aws_bootstrap']=0
    bool['binary']=0
    koopa_can_install_binary && bool['binary']=1
    bool['builder']=0
    koopa_can_build_binary && bool['builder']=1
    bool['update']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    while (("$#"))
    do
        case "$1" in
            # CLI user-accessible flags ----------------------------------------
            '--update')
                bool['update']=1
                shift 1
                ;;
            # Internal flags ---------------------------------------------------
            '--all')
                bool['all']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['binary']}" -eq 1 ]] || [[ "${bool['builder']}" -eq 1 ]]
    then
        app['aws']="$(koopa_locate_aws --allow-missing --allow-system)"
        [[ ! -x "${app['aws']}" ]] && bool['aws_bootstrap']=1
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        koopa_assert_can_install_binary
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    if [[ "${bool['update']}" -eq 1 ]]
    then
        koopa_update_koopa
    fi
    if [[ "${bool['aws_bootstrap']}" -eq 1 ]]
    then
        koopa_install_aws_cli
        if [[ "${bool['builder']}" -eq 1 ]]
        then
            readarray -t app_names <<< "$( \
                koopa_app_dependencies 'aws-cli' \
            )"
            app_names+=('aws-cli')
            koopa_push_app_build "${app_names[@]}"
        fi
    fi
    if [[ "${bool['all']}" -eq 1 ]]
    then
        readarray -t app_names <<< "$( \
            koopa_shared_apps --mode='all' \
        )"
    else
        readarray -t app_names <<< "$( \
            koopa_shared_apps --mode='default' \
        )"
    fi
    for app_name in "${app_names[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        [[ -f "${prefix}/.koopa-install-stdout.log" ]] && continue
        koopa_cli_install "$app_name"
    done
    return 0
}
