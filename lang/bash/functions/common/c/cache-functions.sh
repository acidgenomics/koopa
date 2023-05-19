#!/usr/bin/env bash

koopa_cache_functions() {
    # """
    # Cache all koopa functions.
    # @note Updated 2023-05-18.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['koopa_prefix']}/lang"
    dict['bash_functions']="${dict['lang_prefix']}/bash/functions"
    dict['sh_functions']="${dict['lang_prefix']}/sh/functions"
    koopa_assert_is_dir \
        "${dict['koopa_prefix']}" \
        "${dict['lang_prefix']}" \
        "${dict['bash_functions']}" \
        "${dict['sh_functions']}"
    koopa_cache_functions_dir \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/common" \
        "${dict['bash_functions']}/os/linux/alpine" \
        "${dict['bash_functions']}/os/linux/arch" \
        "${dict['bash_functions']}/os/linux/common" \
        "${dict['bash_functions']}/os/linux/debian" \
        "${dict['bash_functions']}/os/linux/fedora" \
        "${dict['bash_functions']}/os/linux/opensuse" \
        "${dict['bash_functions']}/os/linux/rhel" \
        "${dict['bash_functions']}/os/macos" \
        "${dict['sh_functions']}"
    return 0
}
