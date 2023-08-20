#!/usr/bin/env bash

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
    build_deps=('gcc' 'ldc' 'make' 'python3.11')
    deps=('bzip2' 'lz4' 'xz' 'zlib')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    app['cc']="$(koopa_locate_gcc)"
    app['make']="$(koopa_locate_make)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['ldc']="$(koopa_app_prefix 'ldc')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/biod/sambamba/archive/refs/tags/\
v${dict['version']}.tar.gz"
    export CC="${app['cc']}"
    export LIBRARY_PATH="${LIBRARY_PATH:?}"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    # Ensure that we're using our compiler and not baked in 'gcc'.
    koopa_find_and_replace_in_file \
        --pattern='^(CC=gcc)$' \
        --regex \
        --replacement='# \1' \
        'Makefile'
    # Clang doesn't currently support 'flto=full'.
    # > koopa_find_and_replace_in_file \
    # >     --pattern='^(LDFLAGS     = -L=-flto=full)$' \
    # >     --regex \
    # >     --replacement='# \1' \
    # >     'Makefile'
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
