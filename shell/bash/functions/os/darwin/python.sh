#!/usr/bin/env bash

koopa::macos_install_pytaglib() { # {{{1
    # """
    # Install pytaglib.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew pip
    brew install taglib &>/dev/null
    pip install \
        --global-option='build_ext' \
        --global-option='-I/usr/local/include/' \
        --global-option='-L/usr/local/lib' \
        pytaglib
    return 0
}

koopa::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2020-07-30.
    # """
    local file framework_dir name name_fancy pos reinstall url version
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
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
    name_fancy='Python'
    name='python'
    version="$(koopa::variable "$name")"
    framework_dir='/Library/Frameworks/Python.framework'
    if ! koopa::is_current_version "$name" || [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$framework_dir"
    fi
    [[ -d "$framework_dir" ]] && return 0
    koopa::install_start "$name_fancy" "$framework_dir"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="python-${version}-macosx10.9.pkg"
        url="https://www.python.org/ftp/python/${version}/${file}"
        koopa::download "$url"
        sudo installer -pkg "$file" -target /
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2020-07-21.
    # """
    local name_fancy
    name_fancy='Python framework'
    koopa::uninstall_start "$name_fancy"
    koopa::rm -S \
        '/Library/Frameworks/Python.framework' \
        '/Applications/Python'*
    koopa::remove_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "$name_fancy"
    return 0
}

