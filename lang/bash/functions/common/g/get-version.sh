#!/usr/bin/env bash

# FIXME Add support for 'koopa_macos_xcode_clt_version'.

koopa_get_version() {
    # """
    # Get the version of an installed program.
    # @note Updated 2022-08-27.
    #
    # Option 1: direct app input mode.
    # Option 2: specify app and bin names.
    #
    # @usage koopa_get_version PATH...
    #
    # @examples
    # > koopa_get_version \
    # >     '/opt/koopa/bin/R' \
    # >     '/opt/koopa/bin/python3'
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local -A dict
        dict['cmd']="$cmd"
        dict['bn']="$(koopa_basename "${dict['cmd']}")"
        dict['bn_snake']="$(koopa_snake_case "${dict['bn']}")"
        dict['version_arg']="$(koopa_get_version_arg "${dict['bn']}")"
        dict['version_fun']="koopa_${dict['bn_snake']}_version"
        if koopa_is_function "${dict['version_fun']}"
        then
            if [[ -x "${dict['cmd']}" ]] && \
                [[ ! -d "${dict['cmd']}" ]] && \
                koopa_is_installed "${dict['cmd']}"
            then
                dict['str']="$("${dict['version_fun']}" "${dict['cmd']}")"
            else
                dict['str']="$("${dict['version_fun']}")"
            fi
            [[ -n "${dict['str']}" ]] || return 1
            koopa_print "${dict['str']}"
            continue
        fi
        [[ -x "${dict['cmd']}" ]] || return 1
        [[ ! -d "${dict['cmd']}" ]] || return 1
        koopa_is_installed "${dict['cmd']}" || return 1
        dict['cmd']="$(koopa_realpath "${dict['cmd']}")"
        dict['str']="$("${dict['cmd']}" "${dict['version_arg']}" 2>&1 || true)"
        [[ -n "${dict['str']}" ]] || return 1
        dict['str']="$(koopa_extract_version "${dict['str']}")"
        [[ -n "${dict['str']}" ]] || return 1
        koopa_print "${dict['str']}"
    done
    return 0
}
