#!/usr/bin/env bash

_koopa_cache_functions() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['prefix']="$(_koopa_koopa_prefix)"
    dict['lang_prefix']="${dict['prefix']}/lang"
    dict['bash_prefix']="${dict['lang_prefix']}/bash"
    dict['sh_prefix']="${dict['lang_prefix']}/sh"
    dict['zsh_prefix']="${dict['lang_prefix']}/zsh"
    _koopa_cache_functions_dirs \
        "${dict['bash_prefix']}/include/functions.sh" \
        "${dict['bash_prefix']}/functions"
    _koopa_cache_functions_dirs \
        "${dict['sh_prefix']}/include/functions.sh" \
        "${dict['sh_prefix']}/functions"
    _koopa_cache_functions_dirs \
        "${dict['zsh_prefix']}/include/functions.sh" \
        "${dict['zsh_prefix']}/functions"
    return 0
}
