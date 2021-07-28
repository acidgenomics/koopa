#!/usr/bin/env bash

koopa::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2021-05-28.
    # """
    local file macos_string macos_version major_version name prefix
    local name_fancy pos reinstall tee url version
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
    major_version="$(koopa::major_version "$version")"
    macos_version="$(koopa::macos_version)"
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
    prefix='/Library/Frameworks/Python.framework'
    if ! koopa::is_current_version "$name" || [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$prefix"
    fi
    if [[ -d "$prefix" ]]
    then
        koopa::alert_is_installed "$name_fancy" "$prefix"
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    tee="$(koopa::locate_tee)"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file="${name}-${version}-${macos_string}.pkg"
        url="https://www.${name}.org/ftp/${name}/${version}/${file}"
        koopa::download "$url"
        sudo installer -pkg "$file" -target /
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    python="${name}${major_version}"
    python="${prefix}/Versions/Current/bin/${python}"
    koopa::assert_is_file "$python"
    koopa::configure_python "$python"
    koopa::install_success "$name_fancy"
    koopa::alert_restart
    return 0
}

koopa::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2021-05-21.
    # """
    local name_fancy
    name_fancy='Python framework'
    koopa::uninstall_start "$name_fancy"
    koopa::rm -S \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "$name_fancy"
    return 0
}
