#!/usr/bin/env bash

main() {
    # """
    # Install Python framework binary.
    # @note Updated 2022-12-08.
    # """
    local app dict
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['installer']="$(koopa_macos_locate_installer)"
    app['sudo']="$(koopa_locate_sudo)"
    [[ -x "${app['installer']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    dict['framework_prefix']='/Library/Frameworks/Python.framework'
    dict['macos_version']="$(koopa_macos_os_version)"
    dict['name']='python'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['macos_version']}" in
        '10'*)
            dict['macos_string']='macosx10.9'
            ;;
        *)
            dict['macos_string']='macos11'
            ;;
    esac
    dict['major_version']="$(koopa_major_version "${dict['version']}")"
    dict['maj_min_version']="$(koopa_major_minor_version "${dict['version']}")"
    dict['prefix']="${dict['framework_prefix']}/Versions/\
${dict['maj_min_version']}"
    dict['file']="${dict['name']}-${dict['version']}-\
${dict['macos_string']}.pkg"
    dict['url']="https://www.${dict['name']}.org/ftp/${dict['name']}/\
${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    "${app['sudo']}" "${app['installer']}" -pkg "${dict['file']}" -target /
    app['python']="${dict['prefix']}/bin/${dict['name']}\
${dict['major_version']}"
    koopa_assert_is_installed "${app['python']}"
    # Ensure 'python' symlink exists.
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln --sudo \
            "${dict['name']}${dict['major_version']}" "${dict['name']}"
        koopa_cd '/usr/local/bin'
        koopa_ln --sudo \
            "${dict['name']}${dict['major_version']}" "${dict['name']}"
    )
    return 0
}
