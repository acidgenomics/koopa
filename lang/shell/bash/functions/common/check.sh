#!/usr/bin/env bash

koopa::check_azure() { # {{{1
    # """
    # Check Azure VM integrity.
    # @note Updated 2020-07-04.
    # """
    local mount
    koopa::assert_has_no_args "$#"
    koopa::is_azure || return 0
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
    local access code file
    koopa::assert_has_args "$#"
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
        koopa::warning "'${file}' does not exist."
        return 1
    fi
    access="$(koopa::stat_access_octal "$file")"
    if [[ "$access" != "$code" ]]
    then
        koopa::warning "'${file}' current access '${access}' is not '${code}'."
        return 1
    fi
    return 0
}

koopa::check_data_disk() { # {{{1
    # """
    # Check data disk configuration.
    # @note Updated 2020-11-19.
    # """
    local data_disk_link_prefix opt_prefix
    koopa::assert_has_no_args "$#"
    koopa::is_linux || return 0
    # e.g. '/n'.
    data_disk_link_prefix="$(koopa::data_disk_link_prefix)"
    if [[ -L "$data_disk_link_prefix" ]] && [[ ! -e "$data_disk_link_prefix" ]]
    then
        koopa::warning "Invalid symlink: '${data_disk_link_prefix}'."
        return 1
    fi
    # e.g. '/opt/koopa/opt'; or previously '/usr/local/koopa/opt'.
    opt_prefix="$(koopa::opt_prefix)"
    if [[ -L "$opt_prefix" ]] && [[ ! -e "$opt_prefix" ]]
    then
        koopa::warning "Invalid symlink: '${opt_prefix}'."
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
        koopa::warning "Disk usage is ${used}%."
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
    local mnt
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'find'
    mnt="${1:?}"
    if [[ "$(find "$mnt" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]]
    then
        koopa::warning "'${mnt}' is unmounted."
        return 1
    fi
    return 0
}

koopa::check_system() { # {{{1
    # """
    # Check system.
    # @note Updated 2021-08-17.
    # """
    local current expected
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed R
    if ! koopa::is_r_package_installed 'koopa'
    then
        koopa::install_r_koopa
    fi
    koopa::r_koopa --vanilla 'cliCheckSystem'
    koopa::check_exports
    koopa::check_disk
    koopa::check_data_disk
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
        koopa::warning "'${file}' does not exist on disk."
        return 1
    fi
    file="$(koopa::realpath "$file")"
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
