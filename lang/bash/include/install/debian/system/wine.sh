#!/usr/bin/env bash

main() {
    # """
    # Install Wine.
    # @note Updated 2022-01-28.
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
    local -A app
    app['dpkg']="$(koopa_debian_locate_dpkg)"
    koopa_assert_is_executable "${app[@]}"
    koopa_debian_apt_add_wine_repo
    # This is required to install missing libaudio0 dependency.
    koopa_debian_apt_add_wine_obs_repo
    # Enable 32-bit packages.
    koopa_sudo "${app['dpkg']}" --add-architecture 'i386'
    # Old stable version: Use wine, wine32 here.
    koopa_debian_apt_get install \
        'winbind' \
        'x11-apps' \
        'xauth' \
        'xvfb' \
        'winehq-stable'
    return 0
}
