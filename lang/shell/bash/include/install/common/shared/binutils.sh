#!/usr/bin/env bash

# # FIXME Need to improve flex handling:
# checking for flex... flex
# configure: error: cannot find output from flex; giving up

# FIXME Need to rework this:
# checking for libdebuginfod >= 0.179... no
# configure: WARNING: libdebuginfod is missing or unusable; some features may be unavailable.

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
    # - https://tracker.debian.org/pkg/binutils
    # - https://salsa.debian.org/toolchain-team/binutils/-/tree/master/debian
    # """
    local build_deps deps install_args
    build_deps=('bison' 'flex')
    deps=('zlib' 'texinfo')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    install_args=(
        # > -D '--disable-gprofng'
        # > -D '--disable-multilib'
        # > -D '--disable-nls'
        # > -D '--disable-plugins'
        # > -D '--disable-static'
        # > -D '--disable-werror'
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
        # Gold is required for LLVM.
        -D '--enable-gold'
    )
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='binutils' \
        "${install_args[@]}" \
        "$@"
}
