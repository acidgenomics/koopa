#!/usr/bin/env bash

_koopa_macos_enable_plist_file() {
    # """
    # Enable a disabled plist file correponding to a launch agent or daemon.
    # @note Updated 2024-12-03.
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['launchctl']="$(_koopa_macos_locate_launchctl)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_not_file "$@"
    for file in "$@"
    do
        local -A bool dict
        bool['daemon']=0
        bool['sudo']=1
        dict['enabled_file']="$file"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_alert "Enabling '${dict['enabled_file']}'."
        if _koopa_str_detect_fixed \
            --string="${dict['enabled_file']}" \
            --pattern='/LaunchDaemons/'
        then
            bool['daemon']=1
        fi
        if _koopa_str_detect_regex \
            --string="${dict['enabled_file']}" \
            --pattern="^${HOME:?}"
        then
            bool['sudo']=0
        fi
        if [[ "${bool['sudo']}" -eq 1 ]]
        then
            _koopa_assert_is_admin
            _koopa_mv --sudo --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Loading '${dict['enabled_file']}'."
                _koopa_sudo \
                    "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        else
            _koopa_mv --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Loading '${dict['enabled_file']}'."
                "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        fi
    done
    return 0
}
