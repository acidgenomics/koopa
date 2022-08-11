#!/usr/bin/env bash

# FIXME Break out to separate installer. Don't use '--activate-opt' here, as
# it can cause issues with binary package install.

koopa_install_nettle() {
    # """
    # Need to make sure libhogweed installs.
    # - https://stackoverflow.com/questions/9508851/how-to-compile-gnutls
    # - https://noknow.info/it/os/install_nettle_from_source
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nettle.html
    # - https://stackoverflow.com/questions/7965990
    # - https://gist.github.com/morgant/1753095
    # """
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='m4' \
        --installer='gnu-app' \
        --name='nettle' \
        -D '--disable-dependency-tracking' \
        -D '--enable-mini-gmp' \
        -D '--enable-shared' \
        "$@"
}
