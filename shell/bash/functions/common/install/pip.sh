#!/usr/bin/env bash

koopa::install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-08-13.
    # """
    local file name pos python reinstall tmp_dir url
    name='pip'
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            '')
                shift 1
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
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed "$python"
    if [[ "$reinstall" -eq 0 ]]
    then
        if koopa::is_python_package_installed --python="$python" "$name"
        then
            koopa::note "Python package '${name}' is already installed."
            return 0
        fi
    fi
    koopa::install_start "$name"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='get-pip.py'
        url="https://bootstrap.pypa.io/${file}"
        koopa::download "$url"
        "$python" "$file" --no-warn-script-location
    )
    koopa::rm "$tmp_dir"
    koopa::is_symlinked_app "$python" && koopa::link_app python
    koopa::install_success "$name"
    return 0
}
