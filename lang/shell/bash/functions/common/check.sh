#!/usr/bin/env bash

koopa::check_access_human() { # {{{1
    # """
    # Check if file or directory has expected human readable access.
    # @note Updated 2020-07-04.
    # """
    local access code file
    koopa::assert_has_args "$#"
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warn "'${file}' does not exist."
        return 1
    fi
    access="$(koopa::stat_access_human "$file")"
    if [[ "$access" != "$code" ]]
    then
        koopa::warn "'${file}' current access '${access}' is not '${code}'."
        return 1
    fi
    return 0
}

koopa::check_access_octal() { # {{{1
    # """
    # Check if file or directory has expected octal access.
    # @note Updated 2020-07-04.
    # """
    local access code file
    koopa::assert_has_args "$#"
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warn "'${file}' does not exist."
        return 1
    fi
    access="$(koopa::stat_access_octal "$file")"
    if [[ "$access" != "$code" ]]
    then
        koopa::warn "'${file}' current access '${access}' is not '${code}'."
        return 1
    fi
    return 0
}

koopa::check_disk() { # {{{1
    # """
    # Check that disk has enough free space.
    # @note Updated 2020-06-30.
    # """
    local limit used
    limit=90
    used="$(koopa::disk_pct_used "$@")"
    if [[ "$used" -gt "$limit" ]]
    then
        koopa::warn "Disk usage is ${used}%."
        return 1
    fi
    return 0
}

koopa::check_exports() { # {{{1
    # """
    # Check exported environment variables.
    # @note Updated 2020-07-05.
    #
    # Warn the user if they are setting unrecommended values.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_rstudio && return 0
    local vars
    vars=(
        'JAVA_HOME'
        'LD_LIBRARY_PATH'
        'PYTHONHOME'
        'R_HOME'
    )
    koopa::warn_if_export "${vars[@]}"
    return 0
}

koopa::check_group() { # {{{1
    # """
    # Check if file or directory has an expected group.
    # @note Updated 2020-07-04.
    # """
    local code file group
    koopa::assert_has_args "$#"
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warn "'${file}' does not exist."
        return 1
    fi
    group="$(koopa::stat_group "$file")"
    if [[ "$group" != "$code" ]]
    then
        koopa::warn "'${file}' current group '${group}' is not '${code}'."
        return 1
    fi
    return 0
}

# FIXME Rework using app/dict approach.
koopa::check_mount() { # {{{1
    # """
    # Check if a drive is mounted.
    # @note Updated 2021-10-22.
    #
    # @examples
    # koopa::check_mount '/mnt/scratch'
    # """
    local mnt nfiles wc
    koopa::assert_has_args "$#"
    mnt="${1:?}"
    if [[ ! -r "$mnt" ]] || [[ ! -d "$mnt" ]]
    then
        koopa::warn "'${mnt}' is not a readable directory."
        return 1
    fi
    wc="$(koopa::locate_wc)"
    # FIXME Consider adding '--count' support here.
    nfiles="$( \
        koopa::find \
            --prefix="$mnt" \
            --min-depth=1 \
            --max-depth=1 \
        | "$wc" -l \
    )"
    if [[ "$nfiles" -eq 0 ]]
    then
        koopa::warn "'${mnt}' is unmounted and/or empty."
        return 1
    fi
    return 0
}

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2022-01-21.
    # """
    local current expected
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed R
    if ! koopa::is_r_package_installed 'koopa'
    then
        koopa::install_r_koopa
    fi
    koopa::activate_conda
    koopa::r_koopa --vanilla 'cliCheckSystem'
    koopa::check_exports
    koopa::check_disk
    return 0
}

koopa::check_user() { # {{{1
    # """
    # Check if file or directory is owned by an expected user.
    # @note Updated 2020-07-04.
    # """
    local current_user expected_user file
    koopa::assert_has_args "$#"
    file="${1:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warn "'${file}' does not exist on disk."
        return 1
    fi
    file="$(koopa::realpath "$file")"
    expected_user="${2:?}"
    current_user="$(koopa::stat_user "$file")"
    if [[ "$current_user" != "$expected_user" ]]
    then
        koopa::warn "'${file}' user '${current_user}' is not \
'${expected_user}'."
        return 1
    fi
    return 0
}

koopa::check_version() { # {{{1
    # """
    # Check that program is installed and passes minimum version.
    # @note Updated 2020-06-29.
    #
    # How to break a loop with an error code:
    # https://stackoverflow.com/questions/14059342/
    # """
    local current expected status
    koopa::assert_has_args "$#"
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
