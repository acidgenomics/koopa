#!/usr/bin/env bash

_koopa_which_function() {
    # """
    # Locate a koopa function automatically.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    _koopa_assert_has_args_eq "$#" 1
    [[ -z "${1:-}" ]] && return 1
    dict['input_key']="${1:?}"
    if _koopa_is_function "${dict['input_key']}"
    then
        _koopa_print "${dict['input_key']}"
        return 0
    fi
    dict['key']="${dict['input_key']}"
    dict['key']="${dict['key']//-/_}"
    dict['key']="${dict['key']//\./}"
    dict['os_id']="$(_koopa_os_id)"
    if _koopa_is_function "_koopa_${dict['os_id']}_${dict['key']}"
    then
        dict['fun']="_koopa_${dict['os_id']}_${dict['key']}"
    elif _koopa_is_rhel_like && \
        _koopa_is_function "_koopa_rhel_${dict['key']}"
    then
        dict['fun']="_koopa_rhel_${dict['key']}"
    elif _koopa_is_debian_like && \
        _koopa_is_function "_koopa_debian_${dict['key']}"
    then
        dict['fun']="_koopa_debian_${dict['key']}"
    elif _koopa_is_fedora_like && \
        _koopa_is_function "_koopa_fedora_${dict['key']}"
    then
        dict['fun']="_koopa_fedora_${dict['key']}"
    elif _koopa_is_linux && \
        _koopa_is_function "_koopa_linux_${dict['key']}"
    then
        dict['fun']="_koopa_linux_${dict['key']}"
    else
        dict['fun']="_koopa_${dict['key']}"
    fi
    _koopa_is_function "${dict['fun']}" || return 1
    _koopa_print "${dict['fun']}"
    return 0
}
