#!/usr/bin/env bash

main() {
    # """
    # Install binutils.
    # @note Updated 2022-11-15.
    #
    # @section Flex / Lex configuration on Ubuntu 22:
    # - https://lists.gnu.org/archive/html/bug-binutils/2016-01/msg00076.html
    # - https://sourceware.org/legacy-ml/binutils/2004-05/msg00339.html
    # - https://gcc.gnu.org/legacy-ml/gcc-help/2014-04/msg00082.html
    # - https://github.com/westes/flex/issues/154
    # - https://news.ycombinator.com/item?id=20269105
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
        # > -D '--enable-interwork'
        # > -D '--enable-ld=default'
        # > -D '--enable-relro'
        # > -D '--enable-targets=all'
        # > -D '--with-mmap'
        # > -D '--with-pic'
        # > -D '--with-system-zlib'
        -D '--disable-debug'
        -D '--disable-dependency-tracking'
        -D '--enable-gold' # for llvm.
        -D '--without-debuginfod'
    )
    if koopa_is_linux
    then
        install_args+=(
            # > -D 'LEX=flex'
            -D 'LEX=touch lex.yy.c'
        )
    fi
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='binutils' \
        "${install_args[@]}" \
        "$@"
}
