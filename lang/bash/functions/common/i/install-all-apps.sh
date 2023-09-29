#!/usr/bin/env bash

koopa_install_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2023-09-27.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local -A bool dict
    local -a app_names push_apps
    local app_name
    bool['push']=0
    bool['update']=0
    bool['verbose']=0
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    while (("$#"))
    do
        case "$1" in
            # CLI user-accessible flags ----------------------------------------
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    if [[ "${bool['update']}" -eq 1 ]]
    then
        koopa_update_koopa
    fi
    readarray -t app_names <<< "$(koopa_shared_apps)"
    for app_name in "${app_names[@]}"
    do
        local -a install_args
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        [[ -d "$prefix" ]] && continue
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
    return 0
}
