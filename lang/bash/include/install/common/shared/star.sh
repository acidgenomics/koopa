#!/usr/bin/env bash

# FIXME This isn't currently working correctly with clang on macOS Sonoma.
# Author has only tested using GCC on macOS.

main() {
    # """
    # Install STAR.
    # @note Updated 2023-10-10.
    #
    # Pull request to use 'SYSTEM_HTSLIB=1' to unbundle htslib:
    # https://github.com/alexdobin/STAR/pull/1586
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
    koopa_activate_app --build-only 'coreutils' 'make' 'pkg-config'
    koopa_activate_app 'xz' 'zlib' 'htslib'
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
    make_args+=(
        "--jobs=${dict['jobs']}"
        # > "CPPFLAGS=${CPPFLAGS:?}"
        "CXX=${app['cxx']}"
        # https://github.com/alexdobin/STAR/pull/1586/files
        # > 'SYSTEM_HTSLIB=1'
        'VERBOSE=1'
    )
    if koopa_is_macos
    then
        make_args+=('STARforMacStatic' 'STARlongForMacStatic')
    else
        make_args+=('STAR' 'STARlong')
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src/source'
    dict['patch_common']="${dict['patch_prefix']}/common/star"
    koopa_assert_is_dir "${dict['patch_common']}"
    dict['patch_file_1']="${dict['patch_common']}/01-disable-avx2.patch"
    dict['patch_file_2']="${dict['patch_common']}/02-unbundle-htslib.patch"
    koopa_assert_is_file \
        "${dict['patch_file_1']}" \
        "${dict['patch_file_2']}"
    "${app['patch']}" \
        --input="${dict['patch_file_1']}" \
        --unified \
        --verbose
    "${app['patch']}" \
        --input="${dict['patch_file_2']}" \
        --unified \
        --verbose
    if koopa_is_macos
    then
        dict['patch_macos']="${dict['patch_prefix']}/macos/star"
        koopa_assert_is_dir "${dict['patch_macos']}"
        dict['patch_file_3']="${dict['patch_macos']}/disable-openmp.patch"
        koopa_assert_is_file "${dict['patch_file_3']}"
        "${app['patch']}" \
            --input="${dict['patch_file_3']}" \
            --unified \
            --verbose
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

