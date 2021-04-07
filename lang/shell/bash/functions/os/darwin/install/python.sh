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

# FIXME Need to improve support for macOS 11.
# macos big sur:
# https://www.python.org/ftp/python/3.9.4/python-3.9.4-macos11.pkg
#
# macos catalina:
# https://www.python.org/ftp/python/3.9.4/python-3.9.4-macosx10.9.pkg
koopa::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2021-04-07.
    # """
    local file framework_dir macos_string macos_version name name_fancy pos \
        reinstall url version
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
    macos_string="$(koopa::macos_version)"
    case "$macos_version" in
        11*)
            macos_string='macos11'
            ;;
        10*)
            macos_string='macosx10.9'
            ;;
        *)
            koopa::stop "Unsupported macOS version: '${version}'."
            ;;
    esac
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
        file="python-${version}-${macos_string}.pkg"
        url="https://www.python.org/ftp/python/${version}/${file}"
        koopa::download "$url"
        sudo installer -pkg "$file" -target /
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    koopa::alert_restart
    return 0
}

koopa::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2020-11-18.
    # """
    local name_fancy
    name_fancy='Python framework'
    koopa::uninstall_start "$name_fancy"
    koopa::rm -S \
        '/Library/Frameworks/Python.framework' \
        '/Applications/Python'*
    koopa::delete_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "$name_fancy"
    return 0
}

