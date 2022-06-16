#!/usr/bin/env bash

# FIXME Need to rework support for pkg-config version lookup, programs
# that require custom extraction -- e.g. armadillo, pcre2, etc...

koopa_get_version() {
    # """
    # Get the version of an installed program.
    # @note Updated 2022-06-16.
    #
    # Option 1: direct app input mode.
    # Option 2: specify app and opt names.
    #
    # @examples
    # > koopa_get_version --app-name='R' --opt-name=r'
    # > koopa_get_version '/opt/koopa/opt/r/bin/R'
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [app_name]=''
        [opt_name]=''
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--opt-name='*)
                dict[opt_name]="${1#*=}"
                shift 1
                ;;
            '--opt-name')
                dict[opt_name]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -eq 1 ]]
    then
        dict[cmd]="${1:?}"
    else
        koopa_assert_is_set \
            '--app-name' "${dict[app_name]}" \
            '--opt-name' "${dict[opt_name]}"
        dict[cmd]="${dict[opt_prefix]}/${dict[opt_name]}/bin/${dict[app_name]}"
    fi
    [[ -x "${dict[cmd]}" ]] || return 1
    [[ -d "${dict[cmd]}" ]] && return 1
    koopa_is_installed "${dict[cmd]}" || return 1
    dict[cmd]="$(koopa_realpath "${dict[cmd]}")"
    dict[bn]="$(koopa_basename "${dict[cmd]}")"
    dict[bn_snake]="$(koopa_snake_case_simple "${dict[bn]}")"
    dict[version_arg]="$(__koopa_get_version_arg "${dict[bn]}")"
    dict[version_fun]="koopa_${dict[bn_snake]}_version"
    if koopa_is_function "${dict[version_fun]}"
    then
        dict[str]="$("${dict[version_fun]}" "${dict[cmd]}")"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
        return 0
    fi
    dict[str]="$("${dict[cmd]}" "${dict[version_arg]}" 2>&1 || true)"
    [[ -n "${dict[str]}" ]] || return 1
    dict[str]="$(koopa_extract_version "${dict[str]}")"
    [[ -n "${dict[str]}" ]] || return 1
    koopa_print "${dict[str]}"
    return 0
}
