#!/usr/bin/env bash

# FIXME Need to wrap this in our 'install_app' function.

koopa::debian_install_wine() { # {{{1
    # """
    # Install Wine.
    # @note Updated 2021-11-02.
    #
    # aptitude will return more informative error messages on held package
    # errors, such as with missing libaudio0 dependency.
    #
    # dpkg alternative for .deb file installation:
    # https://unix.stackexchange.com/questions/159094/
    # > sudo dpkg -i /path/to/deb/file
    # > sudo apt-get install -f
    #
    # @seealso
    # - https://wiki.winehq.org/Debian
    # - https://forum.winehq.org/viewtopic.php?f=8&t=32192
    # - https://forum.winehq.org/viewtopic.php?t=31261
    # - https://askubuntu.com/questions/1145473/how-do-i-install-libfaudio0
    # - https://github.com/scottyhardy/docker-wine
    # - https://github.com/baztian/docker-wine/blob/master/Dockerfile
    # - https://gist.github.com/cschiewek/246a244ba23da8b9f0e7b11a68bf3285
    # - https://gist.github.com/paul-krohn/e45f96181b1cf5e536325d1bdee6c949
    # """
    local app dict
    echo 'FIXME 1'
    koopa::assert_has_no_args "$#"
    echo 'FIXME 2'
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_apt_get)"
        [dpkg]="$(koopa::debian_locate_dpkg)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [name_fancy]='Wine'
    )
    echo 'FIXME 3'
    if koopa::is_installed 'wine'
    then
        koopa::alert_is_installed "${dict[name_fancy]}"
        return 0
    fi
    koopa::install_start "${dict[name_fancy]}"
    echo 'FIXME 4'
    koopa::debian_apt_add_wine_repo
    # This is required to install missing libaudio0 dependency.
    echo 'FIXME 5'
    koopa::debian_apt_add_wine_obs_repo
    # Enable 32-bit packages.
    "${app[sudo]}" "${app[dpkg]}" --add-architecture 'i386'
    # Old stable version: Use wine, wine32 here.
    koopa::debian_apt_get install \
        'winbind' \
        'x11-apps' \
        'xauth' \
        'xvfb'
    # Install latest stable version of Wine.
    "${app[sudo]}" DEBIAN_FRONTEND='noninteractive' \
        "${app[apt_get]}" --yes install \
            --install-recommends \
            'winehq-stable'
    koopa::install_success "${dict[name_fancy]}"
    return 0
}

koopa::debian_uninstall_wine() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2021-06-14.
    # """
    koopa::debian_apt_remove 'wine-*'
    koopa::debian_apt_delete_repo 'wine' 'wine-obs'
}
