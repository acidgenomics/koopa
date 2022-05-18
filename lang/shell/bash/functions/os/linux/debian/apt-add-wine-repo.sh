#!/usr/bin/env bash

koopa_debian_apt_add_wine_repo() {
    # """
    # Add WineHQ repo.
    # @note Updated 2021-11-10.
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_wine_key
    koopa_debian_apt_add_repo \
        --name-fancy='Wine' \
        --name='wine' \
        --url="https://dl.winehq.org/wine-builds/$(koopa_os_id)/" \
        --distribution="$(koopa_os_codename)" \
        --component='main'
    return 0
}
