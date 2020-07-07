#!/usr/bin/env bash

koopa::check_azure() { # {{{1
    # """
    # Check Azure VM integrity.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_azure || return 0
    local mount
    mount='/mnt/resource'
    if [[ -e "$mount" ]]
    then
        koopa::check_user "$mount" 'root'
        koopa::check_group "$mount" 'root'
        koopa::check_access_octal "$mount" '1777'
    fi
    koopa::check_mount '/mnt/rdrive'
    return 0
}

koopa::check_access_human() { # {{{1
    # """
    # Check if file or directory has expected human readable access.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local access code file
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warning "'${file}' does not exist."
        return 1
    fi
    access="$(koopa::stat_access_human "$file")"
    if [[ "$access" != "$code" ]]
    then
        koopa::warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

koopa::check_access_octal() { # {{{1
    # """
    # Check if file or directory has expected octal access.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local access code file
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warning "'${file}' does not exist."
        return 1
    fi
    access="$(koopa::stat_access_octal "$file")"
    if [[ "$access" != "$code" ]]
    then
        koopa::warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

koopa::check_data_disk() { # {{{1
    # """
    # Check data disk configuration.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    # e.g. '/n'.
    local data_disk_link_prefix
    data_disk_link_prefix="$(koopa::data_disk_link_prefix)"
    if [[ -L "$data_disk_link_prefix" ]] && [[ ! -e "$data_disk_link_prefix" ]]
    then
        koopa::warning "Data disk link error: '${data_disk_link_prefix}'."
    fi
    # e.g. '/usr/local/opt'.
    local app_prefix
    app_prefix="$(koopa::app_prefix)"
    if [[ -L "$app_prefix" ]] && [[ ! -e "$app_prefix" ]]
    then
        koopa::warning "App prefix link error: '${app_prefix}'."
    fi
    return 0
}

koopa::check_disk() { # {{{1
    # """
    # Check that disk has enough free space.
    # @note Updated 2020-06-30.
    # """
    local limit used
    used="$(koopa::disk_pct_used "$@")"
    limit=90
    if [[ "$used" -gt "$limit" ]]
    then
        koopa::warning "Disk usage is ${used}%."
    fi
    return 0
}

koopa::check_group() { # {{{1
    # """
    # Check if file or directory has an expected group.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local code file group
    file="${1:?}"
    code="${2:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warning "'${file}' does not exist."
        return 1
    fi
    group="$(koopa::stat_group "$file")"
    if [[ "$group" != "$code" ]]
    then
        koopa::warning "'${file}' current group '${group}' is not '${code}'."
        return 1
    fi
    return 0
}

koopa::check_mount() { # {{{1
    # """
    # Check if a drive is mounted.
    # Usage of find is recommended over ls here.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed find
    local mnt
    mnt="${1:?}"
    if [[ "$(find "$mnt" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]]
    then
        koopa::warning "'${mnt}' is unmounted."
        return 1
    fi
    return 0
}

koopa::check_user() { # {{{1
    # """
    # Check if file or directory is owned by an expected user.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_args "$#"
    local current_user expected_user file
    file="${1:?}"
    if [[ ! -e "$file" ]]
    then
        koopa::warning "'${file}' does not exist on disk."
        return 1
    fi
    file="$(realpath "$file")"
    expected_user="${2:?}"
    current_user="$(koopa::stat_user "$file")"
    if [[ "$current_user" != "$expected_user" ]]
    then
        koopa::warning "'${file}' user '${current_user}' is not \
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
    koopa::assert_has_args "$#"
    local current expected status
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

