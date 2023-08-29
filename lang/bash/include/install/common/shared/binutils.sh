#!/usr/bin/env bash

main() {
    # """
    # Install binutils.
    # @note Updated 2023-08-29.
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
    local -a build_deps conf_args deps install_args
    local conf_arg
    build_deps=('bison' 'flex')
    deps=('zlib' 'texinfo')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    conf_args=(
        # > '--disable-multilib'
        # > '--disable-nls'
        # > '--disable-plugins'
        # > '--disable-static'
        # > '--disable-werror'
        # > '--enable-64-bit-bfd'
        # > '--enable-default-execstack=no'
        # > '--enable-deterministic-archives'
        # > '--enable-interwork'
        # > '--enable-ld=default'
        # > '--enable-relro'
        # > '--enable-targets=all'
        # > '--with-mmap'
        # > '--with-pic'
        # > '--with-system-zlib'
        '--disable-debug'
        '--disable-dependency-tracking'
        # gprofng currently has a weird bison detection issue on Linux.
        '--disable-gprofng'
        # gold is required for llvm.
        '--enable-gold'
        '--without-debuginfod'
    )
    if koopa_is_linux
    then
        conf_args+=(
            # > 'LEX=flex'
            'LEX=touch lex.yy.c'
        )
    fi
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app --jobs=1 "${install_args[@]}"
    return 0
}
