#!/usr/bin/env bash

koopa_add_monorepo_config_link() {
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local subdir
    koopa_assert_has_args "$#"
    koopa_assert_has_monorepo
    dict['prefix']="$(koopa_monorepo_prefix)"
    for subdir in "$@"
    do
        koopa_add_config_link \
            "${dict['prefix']}/${subdir}" \
            "$subdir"
    done
    return 0
}
