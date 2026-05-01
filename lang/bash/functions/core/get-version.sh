#!/usr/bin/env bash

# FIXME Add support for '_koopa_macos_xcode_clt_version'.

_koopa_get_version() {
    # """
    # Get the version of an installed program.
    # @note Updated 2022-08-27.
    #
    # Option 1: direct app input mode.
    # Option 2: specify app and bin names.
    #
    # @usage _koopa_get_version PATH...
    #
    # @examples
    # > _koopa_get_version \
    # >     '/opt/koopa/bin/R' \
    # >     '/opt/koopa/bin/python3'
    # """
    local cmd
    _koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local -A dict
        dict['cmd']="$cmd"
        dict['bn']="$(_koopa_basename "${dict['cmd']}")"
        dict['bn_snake']="$(_koopa_snake_case "${dict['bn']}")"
        dict['version_arg']="$(_koopa_get_version_arg "${dict['bn']}")"
        dict['version_fun']="_koopa_${dict['bn_snake']}_version"
        if _koopa_is_function "${dict['version_fun']}"
        then
            if [[ -x "${dict['cmd']}" ]] && \
                [[ ! -d "${dict['cmd']}" ]] && \
                _koopa_is_installed "${dict['cmd']}"
            then
                dict['str']="$("${dict['version_fun']}" "${dict['cmd']}")"
            else
                dict['str']="$("${dict['version_fun']}")"
            fi
            [[ -n "${dict['str']}" ]] || return 1
            _koopa_print "${dict['str']}"
            continue
        fi
        [[ -x "${dict['cmd']}" ]] || return 1
        [[ ! -d "${dict['cmd']}" ]] || return 1
        _koopa_is_installed "${dict['cmd']}" || return 1
        dict['cmd']="$(_koopa_realpath "${dict['cmd']}")"
        dict['str']="$("${dict['cmd']}" "${dict['version_arg']}" 2>&1 || true)"
        [[ -n "${dict['str']}" ]] || return 1
        dict['str']="$(_koopa_extract_version "${dict['str']}")"
        [[ -n "${dict['str']}" ]] || return 1
        _koopa_print "${dict['str']}"
    done
    return 0
}
