#!/usr/bin/env bash

# FIXME CC (e.g. "gcc") check will currently fail on Linux systems with a
# custom compiler defined in PATH. Need to figure out a solution for this.

_koopa_check_build_system() {
    # """
    # Assert that current environment supports building from source.
    # @note Updated 2026-02-17.
    # """
    local -A app dict ver1 ver2
    local key
    _koopa_assert_has_no_args "$#"
    if _koopa_is_macos
    then
        dict['sdk_prefix']="$(_koopa_macos_sdk_prefix)"
        if [[ ! -d "${dict['sdk_prefix']}" ]]
        then
            _koopa_stop "Xcode CLT not installed at '${dict['prefix']}.\
Run 'xcode-select --install' to resolve."
        fi
    fi
    # > _koopa_assert_conda_env_is_not_active
    # > _koopa_assert_python_venv_is_not_active
    app['cc']="$(_koopa_locate_cc --only-system)"
    app['git']="$(_koopa_locate_git --allow-system)"
    app['ld']="$(_koopa_locate_ld --only-system)"
    app['make']="$(_koopa_locate_make --only-system)"
    app['perl']="$(_koopa_locate_perl --only-system)"
    app['python']="$(_koopa_locate_python --allow-bootstrap --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    ver1['cc']="$(_koopa_get_version "${app['cc']}")"
    ver1['git']="$(_koopa_get_version "${app['git']}")"
    ver1['make']="$(_koopa_get_version "${app['make']}")"
    ver1['perl']="$(_koopa_get_version "${app['perl']}")"
    ver1['python']="$(_koopa_get_version "${app['python']}")"
    if _koopa_is_macos
    then
        case "${ver1['cc']}" in
            '16.0.0.0.1.1724870825')
                _koopa_stop "Unsupported cc: ${app['cc']} ${ver1['cc']}."
                ;;
        esac
        # Clang.
        ver2['cc']='14.0'
    elif _koopa_is_linux
    then
        # GCC.
        ver2['cc']='7.0'
    fi
    ver2['git']='1.8'
    ver2['make']='3.8'
    ver2['perl']='5.16'
    ver2['python']='3.6'
    for key in "${!ver1[@]}"
    do
        if ! _koopa_compare_versions "${ver1[$key]}" -ge "${ver2[$key]}"
        then
            _koopa_stop "Unsupported ${key}: ${app[$key]} \
(${ver1[$key]} < ${ver2[$key]})."
        fi
    done
    return 0
}
