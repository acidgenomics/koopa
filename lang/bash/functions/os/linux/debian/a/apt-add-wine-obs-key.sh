#!/usr/bin/env bash

koopa_debian_apt_add_wine_obs_key() {
    # """
    # Add the Wine OBS openSUSE key.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['name']='wine-obs'
    dict['os_string']="$(koopa_os_string)"
    case "${dict['os_string']}" in
        'debian-10')
            dict['subdir']='Debian_10'
            ;;
        'debian-11')
            dict['subdir']='Debian_11'
            ;;
        'ubuntu-18')
            dict['subdir']='xUbuntu_18.04'
            ;;
        'ubuntu-20')
            dict['subdir']='xUbuntu_20.04'
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict['os_string']}'."
            ;;
    esac
    dict['url']="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian/${dict['subdir']}/Release.key"
    koopa_debian_apt_add_key \
        --name="${dict['name']}" \
        --url="${dict['url']}"
    return 0
}
