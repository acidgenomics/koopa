#!/usr/bin/env bash

koopa_debian_apt_add_wine_obs_repo() {
    # """
    # Add Wine OBS openSUSE repo.
    # @note Updated 2021-11-10.
    #
    # Required to install libfaudio0 dependency for Wine on Debian 10+.
    #
    # @seealso
    # - https://wiki.winehq.org/Debian
    # - https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/
    # - https://forum.winehq.org/viewtopic.php?f=8&t=32192
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [base_url]="https://download.opensuse.org/repositories/\
Emulators:/Wine:/Debian"
        [distribution]='./'
        [name]='wine-obs'
        [name_fancy]='Wine OBS'
        [os_string]="$(koopa_os_string)"
    )
    case "${dict[os_string]}" in
        'debian-10')
            dict[url]="${dict[base_url]}/Debian_10/"
            ;;
        'debian-11')
            dict[url]="${dict[base_url]}/Debian_11/"
            ;;
        'ubuntu-18')
            dict[url]="${dict[base_url]}/xUbuntu_18.04/"
            ;;
        'ubuntu-20')
            dict[url]="${dict[base_url]}/xUbuntu_20.04/"
            ;;
        *)
            koopa_stop "Unsupported OS: '${dict[os_string]}'."
            ;;
    esac
    koopa_debian_apt_add_wine_obs_key
    koopa_debian_apt_add_repo \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --url="${dict[url]}" \
        --distribution="${dict[distribution]}"
    return 0
}
