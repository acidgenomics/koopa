#!/usr/bin/env bash

koopa_macos_enable_plist_file() {
    # """
    # Enable a disabled plist file correponding to a launch agent or daemon.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['launchctl']="$(koopa_macos_locate_launchctl)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_not_file "$@"
    for file in "$@"
    do

        local -A dict
        dict['daemon']=0
        dict['enabled_file']="$file"
        dict['sudo']=1
        dict['disabled_file']="$(koopa_dirname "${dict['enabled_file']}")/\
disabled/$(koopa_basename "${dict['enabled_file']}")"
        koopa_alert "Enabling '${dict['enabled_file']}'."
        if koopa_str_detect_fixed \
            --string="${dict['enabled_file']}" \
            --pattern='/LaunchDaemons/'
        then
            dict['daemon']=1
        fi
        if koopa_str_detect_regex \
            --string="${dict['enabled_file']}" \
            --pattern="^${HOME:?}"
        then
            dict['sudo']=0
        fi
        case "${dict['sudo']}" in
            '0')
                koopa_mv \
                    "${dict['disabled_file']}" \
                    "${dict['enabled_file']}"
                if [[ "${dict['daemon']}" -eq 1 ]]
                then
                    "${app['launchctl']}" \
                        load "${dict['enabled_file']}"
                fi
                ;;
            '1')
                koopa_mv --sudo \
                    "${dict['disabled_file']}" \
                    "${dict['enabled_file']}"
                if [[ "${dict['daemon']}" -eq 1 ]]
                then
                    "${app['sudo']}" "${app['launchctl']}" \
                        load "${dict['enabled_file']}"
                fi
                ;;
        esac
    done
    return 0
}
