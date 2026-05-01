#!/usr/bin/env bash

_koopa_add_monorepo_config_link() {
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local subdir
    _koopa_assert_has_args "$#"
    _koopa_assert_has_monorepo
    dict['prefix']="$(_koopa_monorepo_prefix)"
    for subdir in "$@"
    do
        _koopa_add_config_link \
            "${dict['prefix']}/${subdir}" \
            "$subdir"
    done
    return 0
}
