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
    local pkg pos prefix python
    python='python3'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    koopa::is_installed "$python" || return 1
    local prefix
    prefix="$(koopa::python_site_packages_prefix "$python")"
    for pkg in "$@"
    do
        if [[ ! -d "${prefix}/${pkg}" ]] && [[ ! -f "${prefix}/${pkg}.py" ]]
        then
            return 1
        fi
    done
    return 0
}

koopa::is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2020-07-04.
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
    local pkg pos r
    r='R'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --r=*)
                r="${1#*=}"
                shift 1
                ;;
            --r)
                r="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::is_installed "$r" || return 1
    # FIXME NEED TO PASS R HERE INSTEAD.
    prefix="$(koopa::r_library_prefix "$r")"
    for pkg in "$@"
    do
        [ -d "${prefix}/${pkg}" ] || return 1
    done
    return 0
}

