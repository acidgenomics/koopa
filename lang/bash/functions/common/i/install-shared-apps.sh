#!/usr/bin/env bash

koopa_install_shared_apps() {
    # """
    # Build and install multiple shared apps from source.
    # @note Updated 2023-10-13.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local -A app bool dict
    local -a app_names push_apps
    local app_name
    koopa_assert_is_owner
    bool['all_supported']=0
    bool['aws_bootstrap']=0
    bool['binary']=0
    bool['push']=0
    bool['update']=0
    bool['verbose']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    while (("$#"))
    do
        case "$1" in
            # CLI user-accessible flags ----------------------------------------
            '--binary')
                bool['binary']=1
                shift 1
                ;;
            '--push')
                bool['push']=1
                shift 1
                ;;
            '--update')
                bool['update']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Internal flags ---------------------------------------------------
            '--all-supported')
                bool['all_supported']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        koopa_assert_can_install_binary
        if [[ "${bool['push']}" -eq 1 ]]
        then
            koopa_stop 'Pushing binary apps is not supported.'
        fi
        app['aws']="$(koopa_locate_aws --allow-missing --allow-system)"
        [[ ! -x "${app['aws']}" ]] && bool['aws_bootstrap']=1
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
        koopa_install_aws_cli --no-dependencies
    fi
    if [[ "${bool['all_supported']}" -eq 1 ]]
    then
        readarray -t app_names <<< "$(koopa_shared_apps --mode='all-supported')"
    else
        readarray -t app_names <<< "$(koopa_shared_apps)"
    fi
    for app_name in "${app_names[@]}"
    do
        local -a install_args
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        [[ -d "$prefix" ]] && continue
        [[ "${bool['binary']}" -eq 1 ]] && install_args+=('--binary')
        [[ "${bool['verbose']}" -eq 1 ]] && install_args+=('--verbose')
        install_args+=("$app_name")
        koopa_cli_install "${install_args[@]}"
        push_apps+=("$app_name")
    done
    if [[ "${bool['push']}" -eq 1 ]] && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    if [[ "${bool['aws_bootstrap']}" -eq 1 ]]
    then
        koopa_cli_install --reinstall 'aws-cli'
    fi
    return 0
}
