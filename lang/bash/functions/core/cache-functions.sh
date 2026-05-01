#!/usr/bin/env bash

_koopa_cache_functions() {
    local -A dict
    local dir
    _koopa_assert_has_no_args "$#"
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['_koopa_prefix']}/lang"
    dict['bash_functions']="${dict['lang_prefix']}/bash/functions"
    dict['sh_functions']="${dict['lang_prefix']}/sh/functions"
    _koopa_assert_is_dir \
        "${dict['_koopa_prefix']}" \
        "${dict['lang_prefix']}" \
        "${dict['bash_functions']}" \
        "${dict['sh_functions']}"
    _koopa_cache_functions_dirs \
        "${dict['bash_functions']}/activate.sh" \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/alias" \
        "${dict['bash_functions']}/core" \
        "${dict['bash_functions']}/export" \
        "${dict['bash_functions']}/is" \
        "${dict['bash_functions']}/macos" \
        "${dict['bash_functions']}/prefix" \
        "${dict['bash_functions']}/xdg"
    _koopa_cache_functions_dirs \
        "${dict['bash_functions']}/common.sh" \
        "${dict['bash_functions']}/activate" \
        "${dict['bash_functions']}/add" \
        "${dict['bash_functions']}/alert" \
        "${dict['bash_functions']}/alias" \
        "${dict['bash_functions']}/assert" \
        "${dict['bash_functions']}/aws" \
        "${dict['bash_functions']}/cli" \
        "${dict['bash_functions']}/core" \
        "${dict['bash_functions']}/current" \
        "${dict['bash_functions']}/docker" \
        "${dict['bash_functions']}/export" \
        "${dict['bash_functions']}/find" \
        "${dict['bash_functions']}/git" \
        "${dict['bash_functions']}/install" \
        "${dict['bash_functions']}/is" \
        "${dict['bash_functions']}/locate" \
        "${dict['bash_functions']}/macos" \
        "${dict['bash_functions']}/prefix" \
        "${dict['bash_functions']}/print" \
        "${dict['bash_functions']}/python" \
        "${dict['bash_functions']}/r" \
        "${dict['bash_functions']}/reinstall" \
        "${dict['bash_functions']}/salmon" \
        "${dict['bash_functions']}/uninstall" \
        "${dict['bash_functions']}/xdg"
    _koopa_cache_functions_dir \
        "${dict['bash_functions']}/os/linux/alpine" \
        "${dict['bash_functions']}/os/linux/arch" \
        "${dict['bash_functions']}/os/linux/common" \
        "${dict['bash_functions']}/os/linux/debian" \
        "${dict['bash_functions']}/os/linux/fedora" \
        "${dict['bash_functions']}/os/linux/opensuse" \
        "${dict['bash_functions']}/os/linux/rhel" \
        "${dict['bash_functions']}/os/macos"
    _koopa_cache_functions_dir \
        "${dict['sh_functions']}"
    return 0
}
