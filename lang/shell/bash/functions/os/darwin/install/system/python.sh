#!/usr/bin/env bash

# FIXME Rework this using 'app' and 'dict' array approach.
# FIXME Finish reworking dict approach here.
# FIXME Allow the user to pass in version here.
# FIXME Should we wrap this in 'koopa::install...' call with '--no-custom-prefix' flag set?
# FIXME Or consider setting a '--system' flag that doesn't attempt to change permissions...
# FIXME Rework our tmpdir handling here..
# FIXME Need to rework these using wrappers.

koopa::macos_install_python_framework() { # {{{1
    # """
    # Install Python framework.
    # @note Updated 2021-10-29.
    # """
    local app dict file macos_string macos_version major_version name prefix
    local name_fancy url version
    declare -A app=(
        [installer]="$(koopa::locate_installer)"
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [macos_version]="$(koopa::macos_version)"
        [name]='python'
        [name_fancy]='Python'
        [prefix]='/Library/Frameworks/Python.framework'
        [reinstall]=0
        [tmp_dir]="$(koopa::tmp_dir)"
        [tmp_log_file]="$(koopa::tmp_log_file)"
        [version]="$(koopa::variable "${dict[name]}")"
    )
    while (("$#"))
    do
        case "$1" in
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    dict[major_version]="$(koopa::major_version "${dict[version]}")"
    case "${dict[macos_version]}" in
        '11'*)
            dict[macos_string]='macos11'
            ;;
        '10'*)
            dict[macos_string]='macosx10.9'
            ;;
        *)
            koopa::stop "Unsupported macOS version: '${dict[version]}'."
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

# FIXME Rework this as a wrapped install call.
# FIXME Use '--system' flag to handle this?
koopa::macos_uninstall_python_framework() { # {{{1
    # """
    # Uninstall Python framework.
    # @note Updated 2021-05-21.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [name_fancy]='Python framework'
    )
    koopa::uninstall_start "${dict[name_fancy]}"
    koopa::rm --sudo \
        '/Applications/Python'* \
        '/Library/Frameworks/Python.framework'
    koopa::delete_broken_symlinks '/usr/local/bin'
    koopa::uninstall_success "${dict[name_fancy]}"
    return 0
}
