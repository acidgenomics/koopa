#!/usr/bin/env bash

koopa_check_access_human() { # {{{1
    # """
    # Check if file or directory has expected human readable access.
    # @note Updated 2021-01-31.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[access]="$(koopa_stat_access_human "${dict[file]}")"
    if [[ "${dict[access]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current access '${dict[access]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_access_octal() { # {{{1
    # """
    # Check if file or directory has expected octal access.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[access]="$(koopa_stat_access_octal "${dict[file]}")"
    if [[ "${dict[access]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current access '${dict[access]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_disk() { # {{{1
    # """
    # Check that disk has enough free space.
    # @note Updated 2022-01-21.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [limit]=90
        [used]="$(koopa_disk_pct_used "$@")"
    )
    if [[ "${dict[used]}" -gt "${dict[limit]}" ]]
    then
        koopa_warn "Disk usage is ${dict[used]}%."
        return 1
    fi
    return 0
}

koopa_check_exports() { # {{{1
    # """
    # Check exported environment variables.
    # @note Updated 2020-07-05.
    #
    # Warn the user if they are setting unrecommended values.
    # """
    local vars
    koopa_assert_has_no_args "$#"
    koopa_is_rstudio && return 0
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    koopa_warn_if_export "${vars[@]}"
    return 0
}

koopa_check_group() { # {{{1
    # """
    # Check if file or directory has an expected group.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args "$#"
    declare -A dict=(
        [file]="${1:?}"
        [code]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist."
        return 1
    fi
    dict[group]="$(koopa_stat_group "${dict[file]}")"
    if [[ "${dict[group]}" != "${dict[code]}" ]]
    then
        koopa_warn "'${dict[file]}' current group '${dict[group]}' \
is not '${dict[code]}'."
        return 1
    fi
    return 0
}

koopa_check_mount() { # {{{1
    # """
    # Check if a drive is mounted.
    # @note Updated 2022-01-31.
    #
    # @examples
    # > koopa_check_mount '/mnt/scratch'
    # """
    local app dict
    koopa_assert_has_args "$#"
    declare -A app=(
        [wc]="$(koopa_locate_wc)"
    )
    declare -A dict=(
        [prefix]="${1:?}"
    )
    if [[ ! -r "${dict[prefix]}" ]] || [[ ! -d "${dict[prefix]}" ]]
    then
        koopa_warn "'${dict[prefix]}' is not a readable directory."
        return 1
    fi
    dict[nfiles]="$( \
        koopa_find \
            --prefix="${dict[prefix]}" \
            --min-depth=1 \
            --max-depth=1 \
        | "${app[wc]}" -l \
    )"
    if [[ "${dict[nfiles]}" -eq 0 ]]
    then
        koopa_warn "'${dict[prefix]}' is unmounted and/or empty."
        return 1
    fi
    return 0
}

koopa_check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2022-05-06.
    # """
    koopa_assert_has_no_args "$#"
    koopa_check_exports || return 1
    koopa_check_disk '/' || return 1
    if ! koopa_is_r_package_installed 'koopa'
    then
        koopa_install_r_koopa
    fi
    koopa_r_koopa --vanilla 'cliCheckSystem'
    koopa_alert_success 'System passed all checks.'
    return 0
}

koopa_check_user() { # {{{1
    # """
    # Check if file or directory is owned by an expected user.
    # @note Updated 2022-01-31.
    # """
    local dict
    koopa_assert_has_args_eq "$#" 2
    declare -A dict=(
        [file]="${1:?}"
        [expected_user]="${2:?}"
    )
    if [[ ! -e "${dict[file]}" ]]
    then
        koopa_warn "'${dict[file]}' does not exist on disk."
        return 1
    fi
    dict[file]="$(koopa_realpath "${dict[file]}")"
    dict[current_user]="$(koopa_stat_user "${dict[file]}")"
    if [[ "${dict[current_user]}" != "${dict[expected_user]}" ]]
    then
        koopa_warn "'${dict[file]}' user '${dict[current_user]}' \
is not '${dict[expected_user]}'."
        return 1
    fi
    return 0
}

koopa_check_version() { # {{{1
    # """
    # Check that program is installed and passes minimum version.
    # @note Updated 2020-06-29.
    #
    # How to break a loop with an error code:
    # https://stackoverflow.com/questions/14059342/
    # """
    local current expected status
    koopa_assert_has_args "$#"
    IFS='.' read -r -a current <<< "${1:?}"
    IFS='.' read -r -a expected <<< "${2:?}"
    status=0
    for i in "${!current[@]}"
    do
        if [[ ! "${current[$i]}" -ge "${expected[$i]}" ]]
        then
            status=1
            break
        fi
    done
    return "$status"
}
