#!/usr/bin/env bash

# NOTE Hitting this cryptic error with 2.39 on Ubuntu 22:
# # checking for bison... bison
# # checking for bison 3.0.4 or newer... 3.8.2, bad
# # configure: error: Building gprofng requires bison 3.0.4 or later.

main() {
    # """
    # Potentially include:
    # * '--disable-nls'
    # * '--disable-werror'
    # * '--enable-64-bit-bfd'
    # * '--enable-deterministic-archives'
    # * '--enable-gold'
    # * '--enable-interwork'
    # * '--enable-multilib'
    # * '--enable-plugins'
    # * '--enable-targets=all'
    # * '--with-system-zlib'
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     binutils.rb
    # - https://git.alpinelinux.org/aports/tree/main/binutils/APKBUILD
    # """
    koopa_activate_build_opt_prefix 'bison' 'flex'
    koopa_activate_opt_prefix 'zlib' 'texinfo'
    koopa_install_app_passthrough \
        --installer='gnu-app' \
        --name='binutils' \
        -D '--disable-debug' \
        -D '--disable-dependency-tracking' \
        "$@"
}
