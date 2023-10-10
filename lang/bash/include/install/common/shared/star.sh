#!/usr/bin/env bash

## FIXME Need to fix this to build with clang.
## clang: error: unsupported option '-fopenmp'
## Need to patch this:
## https://github.com/alexdobin/STAR/blob/79affaae7d5e70221287762eab4e40679fad87f7/source/Makefile#L48

# FIXME Apply bioconda patch or pull request to unbundle htslib:
# - https://github.com/bioconda/bioconda-recipes/blob/master/recipes/star/
#     patches/0002-donotuse_own_htslib.patch
# - https://github.com/alexdobin/STAR/pull/1586


main() {
    # """
    # Install STAR.
    # @note Updated 2023-10-10.
    #
    # @seealso
    # - https://github.com/alexdobin/STAR/
    # - https://bioconda.github.io/recipes/star/README.html
    # - How to compile without system zlib?
    #   https://github.com/alexdobin/STAR/issues/1932
    # - Unbundle htslib pull request:
    #   https://github.com/alexdobin/STAR/pull/1586
    # """
    local -A app
    local -a make_args
    koopa_activate_app --build-only 'coreutils' 'make'
    koopa_activate_app 'htslib'
    app['cxx']="$(koopa_locate_cxx)"
    app['date']="$(koopa_locate_date)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['patch_prefix']="$(koopa_patch_prefix)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    # Pull request to use 'SYSTEM_HTSLIB=1' to unbundle htslib.
    # https://github.com/alexdobin/STAR/pull/1586
    make_args+=(
        "--jobs=${dict['jobs']}"
        "CXX=${app['cxx']}"
        'VERBOSE=1'
    )
    # Need to set additional flags for Apple Silicon.
    # https://github.com/alexdobin/STAR/issues/1265
    if koopa_is_aarch64
    then
        make_args+=('CXXFLAGS_SIMD=-std=c++11')
    fi
    if koopa_is_macos
    then
        make_args+=('STARforMacStatic' 'STARlongForMacStatic')
    else
        make_args+=('STAR' 'STARlong')
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/source'
    dict['patch_common_prefix']="${dict['patch_prefix']}/common/star"
    koopa_assert_is_dir "${dict['patch_common_prefix']}"
    ## FIXME Need to apply patches.
    koopa_stop 'FIXME patch 1'
    koopa_stop 'FIXME patch 2'
    if koopa_is_macos
    then
        dict['patch_macos_prefix']="${dict['patch_prefix']}/macos/star"
        koopa_assert_is_dir "${dict['patch_macos_prefix']}"
        # FIXME Need to remove openmp.
        koopa_stop 'FIXME'
    fi
    # Makefile is currently hard-coded to look for 'date', which isn't expected
    # GNU on macOS.
    koopa_mkdir 'bin'
    (
        koopa_cd 'bin'
        koopa_ln "${app['date']}" 'date'
    )
    koopa_add_to_path_start "$(koopa_realpath 'bin')"
    koopa_print_env
    koopa_dl 'make args' "${make_args[*]}"
    "${app['make']}" "${make_args[@]}"
    koopa_chmod +x 'STAR' 'STARlong'
    koopa_cp 'STAR' "${dict['prefix']}/bin/STAR"
    koopa_cp 'STARlong' "${dict['prefix']}/bin/STARlong"
    return 0
}
