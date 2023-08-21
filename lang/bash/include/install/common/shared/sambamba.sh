#!/usr/bin/env bash

# FIXME Now hitting this error on macOS:
# ldc2 -wi -I. -I./BioD:./BioD/contrib/msgpack-d/src -g -J. -O3 -release -enable-inlining -boundscheck=off  -L/opt/koopa/app/bzip2/1.0.8/lib -L/opt/koopa/app/lz4/1.9.4/lib -L/opt/koopa/app/xz/5.4.3/lib -L/opt/koopa/app/zlib/1.2.13/lib -of=bin/sambamba-1.0.1 bin/sambamba-1.0.1.o  -L-lz -L-llz4
# ld: can't map file, errno=22 file '/opt/koopa/app/lz4/1.9.4/lib' for architecture x86_64
# clang: error: linker command failed with exit code 1 (use -v to see invocation)
# Error: /usr/bin/clang failed with status: 1
# gmake: *** [Makefile:103: bin/sambamba-1.0.1] Error 1

main() {
    # """
    # Install sambamba.
    # @note Updated 2023-08-20.
    #
    # @seealso
    # - https://github.com/biod/sambamba/blob/master/INSTALL.md
    # - https://github.com/biod/sambamba#compiling-sambamba
    # - https://bioconda.github.io/recipes/sambamba/README.html
    # - https://formulae.brew.sh/formula/sambamba
    # """
    local -A app dict
    local -a build_deps deps
    build_deps=('ldc' 'make' 'python3.11')
    deps=('bzip2' 'lz4' 'xz' 'zlib')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cc']="$(koopa_locate_cc)"
    app['make']="$(koopa_locate_make)"
    koopa_assert_is_executable "${app[@]}"
    dict['ldc']="$(koopa_app_prefix 'ldc')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/biod/sambamba/archive/refs/tags/\
v${dict['version']}.tar.gz"
    export CC="${app['cc']}"
    export LIBRARY_PATH="${LIBRARY_PATH:?}"
    if koopa_is_macos
    then
        # FIXME Take this out if unsetting LDFLAGS works.
        LDFLAGS="$( \
            koopa_gsub \
                --pattern='(\s+)?-Wl,-rpath,[^\s]+' \
                --regex \
                --replacement='' \
                "${LDFLAGS:?}" \
        )"
        unset -v LDFLAGS
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_find_and_replace_in_file \
        --pattern='^(CC=gcc)$' \
        --regex \
        --replacement='# \1' \
        'Makefile'
    if koopa_is_macos
    then
        koopa_find_and_replace_in_file \
            --pattern='^(LDFLAGS     = -L=-flto=full)$' \
            --regex \
            --replacement='# \1' \
            'Makefile'
    fi
    koopa_print_env
    "${app['make']}" \
        CC="$CC" \
        LIBRARY_PATH="$LIBRARY_PATH" \
        VERBOSE=1 \
        release
    if ! koopa_is_aarch64
    then
        "${app['make']}" check
    fi
    koopa_cp \
        "bin/sambamba-${dict['version']}" \
        "${dict['prefix']}/bin/sambamba"
    return 0
}
