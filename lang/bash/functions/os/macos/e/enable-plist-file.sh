#!/usr/bin/env bash

koopa_macos_enable_plist_file() {
    # """
    # Enable a disabled plist file correponding to a launch agent or daemon.
    # @note Updated 2024-12-03.
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['launchctl']="$(koopa_macos_locate_launchctl)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_not_file "$@"
    for file in "$@"
    do
        local -A bool dict
        bool['daemon']=0
        bool['sudo']=1
        dict['enabled_file']="$file"
        dict['disabled_file']="$(koopa_dirname "${dict['enabled_file']}")/\
disabled/$(koopa_basename "${dict['enabled_file']}")"
        koopa_alert "Enabling '${dict['enabled_file']}'."
        if koopa_str_detect_fixed \
            --string="${dict['enabled_file']}" \
            --pattern='/LaunchDaemons/'
        then
            bool['daemon']=1
        fi
        if koopa_str_detect_regex \
            --string="${dict['enabled_file']}" \
            --pattern="^${HOME:?}"
        then
            bool['sudo']=0
        fi
        if [[ "${bool['sudo']}" -eq 1 ]]
        then
            koopa_assert_is_admin
            koopa_mv --sudo --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                koopa_alert "Loading '${dict['enabled_file']}'."
                koopa_sudo \
                    "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        else
            koopa_mv --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                koopa_alert "Loading '${dict['enabled_file']}'."
                "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        fi
    done
    return 0
}
