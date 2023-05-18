#!/usr/bin/env bash

main() {
    # """
    # Need to make sure libhogweed installs.
    # - https://stackoverflow.com/questions/9508851/how-to-compile-gnutls
    # - https://noknow.info/it/os/install_nettle_from_source
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nettle.html
    # - https://stackoverflow.com/questions/7965990
    # - https://gist.github.com/morgant/1753095
    # """
    koopa_activate_app 'gmp' 'm4'
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='nettle' \
        -D '--disable-dependency-tracking' \
        -D '--disable-static' \
        -D '--enable-mini-gmp' \
        -D '--enable-shared'
}
