#!/usr/bin/env bash

# FIXME 2.39 is failing to build on Linux.
# Error seems to be at Makefile:1004...

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
    # - https://docs.pwntools.com/en/stable/install/binutils.html
    # """
    local install_args
    koopa_activate_app --build-only 'bison' 'flex'
    koopa_activate_app 'zlib' 'texinfo'
    install_args=(
        # > -D '--disable-gprofng'
        # > -D '--disable-plugins'
        # > -D '--enable-64-bit-bfd'
        # > -D '--enable-default-execstack=no'
        # > -D '--enable-deterministic-archives'
        # > -D '--enable-ld=default'
        # > -D '--enable-relro'
        # > -D '--with-mmap'
        # > -D '--with-pic'
        # > -D '--with-system-zlib'
        -D '--disable-debug'
        -D '--disable-dependency-tracking'
        -D '--disable-multilib'
        -D '--disable-nls'
        -D '--disable-static'
        -D '--disable-werror'
        -D '--enable-gold'
        -D '--enable-targets=all'
    )
    if koopa_is_linux
    then
        dict['arch']="$(koopa_arch)"
        install_args+=(
            -D "--target=${dict['arch']}-unknown-linux-gnu"
        )
    fi
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='binutils' \
        "${install_args[@]}" \
        "$@"
}
