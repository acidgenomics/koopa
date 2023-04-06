#!/usr/bin/env bash

koopa_macos_disable_plist_file() {
    # """
    # Disable a plist file correponding to a launch agent or daemon.
    # @note Updated 2023-04-05.
    # """
    local -A app
    local file
    koopa_assert_has_args "$#"
    app['launchctl']="$(koopa_macos_locate_launchctl)"
    app['sudo']="$(koopa_locate_sudo)"
    koopa_assert_is_executable "${app[@]}"
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A dict
        dict['daemon']=0
        dict['enabled_file']="$file"
        dict['sudo']=1
        dict['disabled_file']="$(koopa_dirname "${dict['enabled_file']}")/\
disabled/$(koopa_basename "${dict['enabled_file']}")"
        koopa_alert "Disabling '${dict['enabled_file']}'."
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
                if [[ "${dict['daemon']}" -eq 1 ]]
                then
                    "${app['launchctl']}" \
                        unload "${dict['enabled_file']}"
                fi
                koopa_mv \
                    "${dict['enabled_file']}" \
                    "${dict['disabled_file']}"
                ;;
            '1')
                if [[ "${dict['daemon']}" -eq 1 ]]
                then
                    "${app['sudo']}" "${app['launchctl']}" \
                        unload "${dict['enabled_file']}"
                fi
                koopa_mv --sudo \
                    "${dict['enabled_file']}" \
                    "${dict['disabled_file']}"
                ;;
        esac
    done
    return 0
}
