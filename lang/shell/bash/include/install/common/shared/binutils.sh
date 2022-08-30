#!/usr/bin/env bash

# FIXME Hitting this cryptic error on Ubuntu 22:
# # checking for bison... bison
# # checking for bison 3.0.4 or newer... 3.8.2, bad
# # configure: error: Building gprofng requires bison 3.0.4 or later.

main() {
    koopa_activate_build_opt_prefix 'bison'
    koopa_activate_opt_prefix 'zlib' 'texinfo'
    koopa_install_app_internal \
        --installer='gnu-app' \
        --name='binutils' \
        -D '--disable-debug' \
        -D '--disable-dependency-tracking' \
        -D '--disable-nls' \
        -D '--disable-werror' \
        -D '--enable-64-bit-bfd' \
        -D '--enable-deterministic-archives' \
        -D '--enable-gold' \
        -D '--enable-interwork' \
        -D '--enable-multilib' \
        -D '--enable-plugins' \
        -D '--enable-targets=all' \
        -D '--with-system-zlib' \
        "$@"
}
