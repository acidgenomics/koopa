#!/bin/sh
# shellcheck disable=SC2039

_koopa_check_azure() { # {{{1
    # """
    # Check Azure VM integrity.
    # @note Updated 2019-10-31.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_is_azure || return 0
    if [ -e "/mnt/resource" ]
    then
        _koopa_check_user "/mnt/resource" "root"
        _koopa_check_group "/mnt/resource" "root"
        _koopa_check_access_octal "/mnt/resource" "1777"
    fi
    _koopa_check_mount "/mnt/rdrive"
    return 0
}

_koopa_check_access_human() { # {{{1
    # """
    # Check if file or directory has expected human readable access.
    # @note Updated 2020-01-12.
    # """
    _koopa_assert_has_args "$#"
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_human "$file")"
    if [ "$access" != "$code" ]
    then
        _koopa_warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

_koopa_check_access_octal() { # {{{1
    # """
    # Check if file or directory has expected octal access.
    # @note Updated 2020-01-12.
    # """
    _koopa_assert_has_args "$#"
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_octal "$file")"
    if [ "$access" != "$code" ]
    then
        _koopa_warning "'${file}' current access '${access}' is not '${code}'."
    fi
    return 0
}

_koopa_check_group() { # {{{1
    # """
    # Check if file or directory has an expected group.
    # @note Updated 2020-01-12.
    # """
    _koopa_assert_has_args "$#"
    local file
    file="${1:?}"
    local code
    code="${2:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist."
        return 1
    fi
    local group
    group="$(_koopa_stat_group "$file")"
    if [ "$group" != "$code" ]
    then
        _koopa_warning "'${file}' current group '${group}' is not '${code}'."
        return 1
    fi
    return 0
}

_koopa_check_mount() { # {{{1
    # """
    # Check if a drive is mounted.
    # Usage of find is recommended over ls here.
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_args "$#"
    _koopa_is_installed find || return 1
    local mnt
    mnt="${1:?}"
    if [ "$(find "$mnt" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]
    then
        _koopa_warning "'${mnt}' is unmounted."
        return 1
    fi
    return 0
}

_koopa_check_user() { # {{{1
    # """
    # Check if file or directory is owned by an expected user.
    # @note Updated 2020-01-13.
    # """
    _koopa_assert_has_args "$#"
    local file
    file="${1:?}"
    if [ ! -e "$file" ]
    then
        _koopa_warning "'${file}' does not exist on disk."
        return 1
    fi
    file="$(realpath "$file")"
    local expected_user
    expected_user="${2:?}"
    local current_user
    current_user="$(_koopa_stat_user "$file")"
    if [ "$current_user" != "$expected_user" ]
    then
        _koopa_warning "'${file}' user '${current_user}' is not \
'${expected_user}'."
        return 1
    fi
    return 0
}
