#!/usr/bin/env bash

koopa_debian_apt_add_wine_key() {
    # """
    # Add the WineHQ key.
    # @note Updated 2021-11-09.
    #
    # Email: <wine-devel@winehq.org>
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    #
    # > wget -O - https://dl.winehq.org/wine-builds/winehq.key \
    # >     | sudo apt-key add -
    #
    # > wget -nc https://dl.winehq.org/wine-builds/winehq.key
    # > sudo apt-key add winehq.key
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Wine' \
        --name='wine' \
        --url='https://dl.winehq.org/wine-builds/winehq.key'
    return 0
}
