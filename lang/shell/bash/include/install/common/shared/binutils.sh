#!/usr/bin/env bash

# FIXME 2.39 is failing to build on Linux.
#
# NOTE Hitting this cryptic error with 2.39 on Ubuntu 22:
# # checking for bison... bison
# # checking for bison 3.0.4 or newer... 3.8.2, bad
# # configure: error: Building gprofng requires bison 3.0.4 or later.

main() {
    # """
    # Install binutils.
    # @note Updated 2022-11-15.
    #
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
    # - https://www.linuxfromscratch.org/lfs/view/development/
    #     chapter08/binutils.html
    # """
    local install_args
    koopa_activate_app --build-only 'bison' 'flex'
    koopa_activate_app 'zlib' 'texinfo'
    install_args=(
        #-D '--disable-debug'
        #-D '--disable-dependency-tracking'
        #-D '--disable-gold'
        #-D '--disable-gprofng'
        #-D '--disable-multilib'
        #-D '--disable-nls'
        #-D '--disable-plugins'
        #-D '--disable-werror'
        #-D '--enable-64-bit-bfd'
        #-D '--enable-default-execstack=no'
        #-D '--enable-deterministic-archives'
        #-D '--enable-ld=default'
        #-D '--enable-relro'
        #-D '--with-mmap'
        #-D '--with-pic'
        -D '--with-system-zlib'
    )
    if koopa_is_macos
    then
        install_args+=(
            -D '--enable-targets=all'
        )
    else
        install_args+=(
            -D '--enable-targets=all-build'
        )
    fi
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='binutils' \
        "${install_args[@]}" \
        "$@"
}
