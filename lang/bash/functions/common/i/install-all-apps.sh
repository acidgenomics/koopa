#!/usr/bin/env bash

koopa_install_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2023-05-08.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local -A dict
    local -a app_names push_apps
    local app_name
    koopa_assert_has_no_args "$#"
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=6
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    readarray -t app_names <<< "$(koopa_shared_apps)"
    for app_name in "${app_names[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        if [[ -d "$prefix" ]]
        then
            koopa_alert_note "'${app_name}' already installed at '${prefix}'."
            continue
        fi
        koopa_cli_install "$app_name"
        push_apps+=("$app_name")
    done
    if koopa_can_push_binary && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    return 0
}