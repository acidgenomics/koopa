#!/usr/bin/env bash

koopa_add_config_link() {
    # """
    # Add a symlink into the koopa configuration directory.
    # @note Updated 2026-01-05.
    # """
    local -A dict
    koopa_assert_has_args_ge "$#" 2
    dict['config_prefix']="$(koopa_config_prefix)"
    while [[ "$#" -ge 2 ]]
    do
        local -A dict2
        dict2['source_file']="${1:?}"
        dict2['dest_name']="${2:?}"
        shift 2
        koopa_assert_is_existing "${dict2['source_file']}"
        # Error if source file is cloned inside koopa config.
        if koopa_str_detect_fixed \
            --pattern="${dict['config_prefix']}" \
            "${dict2['source_file']}"
        then
            koopa_stop "${dict2['source_file']} is sourced \
inside '${dict['config_prefix']}'."
        fi
        dict2['dest_file']="${dict['config_prefix']}/${dict2['dest_name']}"
        koopa_is_symlink "${dict2['dest_file']}" && continue
        koopa_ln --verbose "${dict2['source_file']}" "${dict2['dest_file']}"
    done
    return 0
}
