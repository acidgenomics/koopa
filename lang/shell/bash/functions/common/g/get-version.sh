#!/usr/bin/env bash

# FIXME Rework this to require app name and opt prefix name...simpler.
# FIXME Also need to support platform-specific locator here...
# FIXME Alternatively, allow pass in of app name and opt prefix name,
# rather than looping per command...

koopa_get_version() {
    # """
    # Get the version of an installed program.
    # @note Updated 2022-06-15.
    #
    # @examples
    # > koopa system version 'R' 'conda' 'coreutils' 'python' 'salmon' 'zsh'
    # """
    local cmd
    koopa_assert_has_args "$#"
    for cmd in "$@"
    do
        local dict
        declare -A dict
        dict[cmd]="$cmd"
        dict[bn1]="$(koopa_basename "${dict[cmd]}")"
        dict[bn]="${dict[bn1]}"
        dict[bn2]="$(__koopa_get_version_name "${dict[bn1]}")"
        if [[ "${dict[bn1]}" != "${dict[bn2]}" ]]
        then
            dict[bn]="${dict[bn2]}"
            dict[cmd]="${dict[bn]}"
        fi
        dict[bn_snake]="$(koopa_snake_case_simple "${dict[bn]}")"
        dict[version_arg]="$(__koopa_get_version_arg "${dict[bn]}")"
        # FIXME Need to also support platform-specific locator here.
        # e.g. this applies to rstudio server on Ubuntu,
        # when 'sbin' is not in path...
        dict[locate_fun]="koopa_locate_${dict[bn_snake]}"
        dict[version_fun]="koopa_${dict[bn_snake]}_version"
        if [[ -x "${dict[cmd]}" ]] && \
            [[ ! -d "${dict[cmd]}" ]] && \
            koopa_is_installed "${dict[cmd]}"
        then
            dict[cmd]="$(koopa_realpath "${dict[cmd]}")"
        fi
        if koopa_is_function "${dict[version_fun]}"
        then
            if [[ -x "${dict[cmd]}" ]] && \
                [[ ! -d "${dict[cmd]}" ]] && \
                koopa_is_installed "${dict[cmd]}"
            then
                dict[str]="$("${dict[version_fun]}" "${dict[cmd]}")"
            else
                dict[str]="$("${dict[version_fun]}")"
            fi
            [[ -n "${dict[str]}" ]] || return 1
            koopa_print "${dict[str]}"
            continue
        fi
        if ! { \
            [[ -x "${dict[cmd]}" ]] && \
            [[ ! -d "${dict[cmd]}" ]] && \
            koopa_is_installed "${dict[cmd]}"; \
        }
        then
            if koopa_is_function "${dict[locate_fun]}"
            then
                dict[cmd]="$("${dict[locate_fun]}")"
            else
                dict[cmd]="$(koopa_which_realpath "${dict[cmd]}")"
            fi
        fi
        koopa_is_installed "${dict[cmd]}" || return 1
        [[ -x "${dict[cmd]}" ]] || return 1
        dict[str]="$("${dict[cmd]}" "${dict[version_arg]}" 2>&1 || true)"
        [[ -n "${dict[str]}" ]] || return 1
        dict[str]="$(koopa_extract_version "${dict[str]}")"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}
