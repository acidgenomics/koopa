#!/usr/bin/env bash

koopa:::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2022-02-10.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [installer]="$(koopa::macos_locate_installer)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [framework_prefix]='/Library/Frameworks/Python.framework'
        [macos_version]="$(koopa::macos_os_version)"
        [name]='python'
        [version]="${INSTALL_VERSION:?}"
    )
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
    dict[major_version]="$(koopa::major_version "${dict[version]}")"
    dict[maj_min_version]="$(koopa::major_minor_version "${dict[version]}")"
    dict[prefix]="${dict[framework_prefix]}/Versions/${dict[maj_min_version]}"
    dict[file]="${dict[name]}-${dict[version]}-${dict[macos_string]}.pkg"
    dict[url]="https://www.${dict[name]}.org/ftp/${dict[name]}/\
${dict[version]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    "${app[sudo]}" "${app[installer]}" -pkg "${dict[file]}" -target /
    app[python]="${dict[prefix]}/bin/${dict[name]}${dict[major_version]}"
    koopa::assert_is_installed "${app[python]}"
    koopa::configure_python "${app[python]}"
    return 0
}
