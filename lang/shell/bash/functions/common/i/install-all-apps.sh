#!/usr/bin/env bash

koopa_install_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2023-03-29.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local app_name app_names dict push_apps
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['mem_gb']="$(koopa_mem_gb)"
        ['mem_gb_cutoff']=6
    )
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "${dict['mem_gb_cutoff']} GB of RAM is required."
    fi
    readarray -t app_names <<< "$(koopa_shared_apps)"
    for app_name in "${app_names[@]}"
    do
        koopa_alert "$app_name"
        if [[ -d "$(koopa_app_prefix --allow-missing "$app_name")" ]]
        then
            continue
        fi
        koopa_cli_install "$app_name"
        push_apps+=("$app_name")
    done
    if koopa_can_install_binary && \
        koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name"
        done
    fi
    return 0
}
