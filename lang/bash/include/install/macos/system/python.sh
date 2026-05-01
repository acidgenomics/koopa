#!/usr/bin/env bash

main() {
    # """
    # Install Python framework binary.
    # @note Updated 2023-06-12.
    # """
    local -A app dict
    app['installer']="$(_koopa_macos_locate_installer)"
    _koopa_assert_is_executable "${app[@]}"
    dict['framework_prefix']='/Library/Frameworks/Python.framework'
    dict['macos_version']="$(_koopa_macos_os_version)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    case "${dict['macos_version']}" in
        '10'*)
            dict['macos_string']='macosx10.9'
            ;;
        *)
            dict['macos_string']='macos11'
            ;;
    esac
    dict['maj_ver']="$(_koopa_major_version "${dict['version']}")"
    dict['maj_min_ver']="$(_koopa_major_minor_version "${dict['version']}")"
    dict['prefix']="${dict['framework_prefix']}/Versions/${dict['maj_min_ver']}"
    dict['url']="https://www.python.org/ftp/python/${dict['version']}/\
python-${dict['version']}-${dict['macos_string']}.pkg"
    _koopa_download "${dict['url']}"
    _koopa_sudo "${app['installer']}" \
        -pkg "$(_koopa_basename "${dict['url']}")" \
        -target '/'
    app['python']="${dict['prefix']}/bin/python${dict['maj_ver']}"
    _koopa_assert_is_executable "${app['python']}"
    (
        _koopa_cd "${dict['prefix']}/bin"
        _koopa_ln --sudo "python${dict['maj_ver']}" 'python'
        _koopa_cd '/usr/local/bin'
        _koopa_ln --sudo "python${dict['maj_ver']}" 'python'
    )
    return 0
}
