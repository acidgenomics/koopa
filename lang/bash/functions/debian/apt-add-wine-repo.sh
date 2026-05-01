#!/usr/bin/env bash

_koopa_debian_apt_add_wine_repo() {
    # """
    # Add WineHQ repo.
    # @note Updated 2023-01-10.
    #
    # - Debian:
    #   https://wiki.winehq.org/Debian
    # - Ubuntu:
    #   https://wiki.winehq.org/Ubuntu
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_wine_key
    _koopa_debian_apt_add_repo \
        --component='main' \
        --distribution="$(_koopa_debian_os_codename)" \
        --name='wine' \
        --url="https://dl.winehq.org/wine-builds/$(_koopa_os_id)/"
    return 0
}
