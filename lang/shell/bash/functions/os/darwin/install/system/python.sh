#!/usr/bin/env bash

koopa::macos_install_python_framework() { # {{{1
    koopa:::install_app \
        --name-fancy='Python framework' \
        --name='python-framework' \
        --platform='macos' \
        --prefix='/Library/Frameworks/Python.framework' \
        --system \
        "$@"
}

koopa::macos_uninstall_python_framework() { # {{{1
    koopa:::uninstall_app \
        --name-fancy='Python framework' \
        --name='python-framework' \
        --platform='macos' \
        --system \
        "$@"
}

koopa:::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [installer]="$(koopa::locate_installer)"
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [macos_version]="$(koopa::macos_version)"
        [name]='python'
        [name_fancy]='Python'
        [prefix]="${INSTALL_PREFIX:?}"
        [reinstall]=0
        [tmp_dir]="$(koopa::tmp_dir)"
        [tmp_log_file]="$(koopa::tmp_log_file)"
        # FIXME I think this doesn't work because you have to move out of array.
    )
    dict[version]="$(koopa::variable "${dict[name]}")"
    dict[major_version]="$(koopa::major_version "${dict[version]}")"
    case "${dict[macos_version]}" in
        '11'* | \
        '12'*)
            dict[macos_string]='macos11'
            ;;
        '10'*)
            dict[macos_string]='macosx10.9'
            ;;
        *)
            koopa::stop "Unsupported macOS version: '${dict[macos_version]}'."
            ;;
    esac
    if ! koopa::is_current_version "${dict[name]}" || \
        [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa::sys_rm "${dict[prefix]}"
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa::alert_is_installed "${dict[name_fancy]}" "${dict[prefix]}"
        return 0
    fi
    koopa::install_start "${dict[name_fancy]}" "${dict[prefix]}"
    dict[file]="${dict[name]}-${dict[version]}-${dict[macos_string]}.pkg"
    dict[url]="https://www.${dict[name]}.org/ftp/${dict[name]}/\
${dict[version]}/${dict[file]}"
    (
        koopa::cd "${dict[tmp_dir]}"
        koopa::download "${dict[url]}" "${dict[file]}"
        "${app[sudo]}" "${app[installer]}" -pkg "${dict[file]}" -target /
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
    koopa::rm "${dict[tmp_dir]}"
    dict[python]="${dict[prefix]}/Versions/Current/bin\
/${dict[name]}${dict[major_version]}"
    koopa::assert_is_executable "${dict[python]}"
    koopa::configure_python "${dict[python]}"
    koopa::install_success "${dict[name_fancy]}"
    return 0
}

koopa:::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2021-11-02.
    # """
    koopa::assert_has_no_args "$#"
    koopa::rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    return 0
}
