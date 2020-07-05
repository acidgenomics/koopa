#!/usr/bin/env bash

koopa::is_array_non_empty() { # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2020-06-29.
    #
    # Particularly useful for checking against readarray return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # """
    koopa::assert_has_args "$#"
    local arr
    arr=("$@")
    [[ "${#arr[@]}" -eq 0 ]] && return 1
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}

# FIXME NEED TO SUPPORT FLAG.
koopa::is_python_package_installed() { # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2020-04-25.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > koopa::str_match_regex "$freeze" "^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390
    # """
    koopa::assert_has_args "$#"
    local pkg
    pkg="${1:?}"
    local python_exe
    python_exe="${2:-python3}"
    koopa::is_installed "$python_exe" || return 1
    local prefix
    prefix="$(koopa::python_site_packages_prefix "$python_exe")"
    [ -d "${prefix}/${pkg}" ]
}

# FIXME NEED TO SUPPORT FLAG.
koopa::is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2020-04-25.
    #
    # This will only return true for user-installed packages.
    #
    # Fast mode: checking the 'site-library' directory.
    #
    # Alternate, slow mode:
    # > Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
    # >     | grep -q "TRUE"
    # """
    koopa::assert_has_args "$#"
    local pkg prefix rscript_exe
    pkg="${1:?}"
    rscript_exe="${2:-Rscript}"
    koopa::is_installed "$rscript_exe" || return 1
    prefix="$(koopa::r_library_prefix "$rscript_exe")"
    [ -d "${prefix}/${pkg}" ]
}

