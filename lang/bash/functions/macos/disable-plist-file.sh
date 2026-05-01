#!/usr/bin/env bash

# NOTE Hit this error when disabling google-drive:
# Unload failed: 5: Input/output error

_koopa_macos_disable_plist_file() {
    # """
    # Disable a plist file correponding to a launch agent or daemon.
    # @note Updated 2024-12-03.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/226253
    # - https://uko.codes/killing-microsoft-defender-on-a-mac
    # """
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['launchctl']="$(_koopa_macos_locate_launchctl)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A bool dict
        bool['daemon']=0
        bool['sudo']=1
        dict['enabled_file']="$file"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_alert "Disabling '${dict['enabled_file']}'."
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
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Unloading '${dict['enabled_file']}'."
                _koopa_sudo \
                    "${app['launchctl']}" unload -w "${dict['enabled_file']}"
            fi
            _koopa_mv --sudo --verbose \
                "${dict['enabled_file']}" \
                "${dict['disabled_file']}"
        else
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Unloading '${dict['enabled_file']}'."
                "${app['launchctl']}" unload -w "${dict['enabled_file']}"
            fi
            _koopa_mv --verbose \
                "${dict['enabled_file']}" \
                "${dict['disabled_file']}"
        fi
    done
    return 0
}
