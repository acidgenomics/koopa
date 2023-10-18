#!/usr/bin/env bash

# FIXME We may only hit this when attempting to build shared on macOS:
# FIXME Hitting this issue with newest version of clang:
#
# SharedMemory.cpp:109:59: error: use of undeclared identifier 'SHM_NORESERVE'
#  109 |     _shmID=shmget(_key, toReserve, IPC_CREAT | IPC_EXCL | SHM_NORESERVE | 0666); //        _shmID = shmget(shmKey, shmSize, IPC_CREAT | SHM_NORESERVE | SHM_HUGETLB | 0666);
#      |                                                           ^
#SharedMemory.cpp:254:72: error: use of undeclared identifier 'SHM_NORESERVE'
#  254 |         _sharedCounterID=shmget(_counterKey, 1, IPC_CREAT | IPC_EXCL | SHM_NORESERVE | 0666);
#      |                                                                        ^
#2 errors generated.
#gmake: *** [Makefile:113: SharedMemory.o] Error 1
#gmake: *** Waiting for unfinished jobs....

main() {
    # """
    # Install STAR.
    # @note Updated 2023-10-18.
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
    local -a build_deps deps make_args
    build_deps=('coreutils' 'make' 'pkg-config')
    ! koopa_is_macos && deps+=('bzip2')
    deps+=('xz' 'zlib' 'htslib')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    if koopa_is_macos
    then
        app['cxx']="$(koopa_locate_clangxx)"
    else
        app['cxx']="$(koopa_locate_cxx --only-system)"
    fi
    app['date']="$(koopa_locate_date)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    app['pkg_config']="$(koopa_locate_pkg_config)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['patch_prefix']="$(koopa_patch_prefix)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    if koopa_is_macos
    then
        dict['clt_maj_ver']="$(koopa_macos_xcode_clt_major_version)"
        if [[ "${dict['clt_maj_ver']}" -ge 15 ]]
        then
            koopa_append_ldflags '-Wl,-ld_classic'
        fi
    fi
    make_args+=(
        "--jobs=${dict['jobs']}"
        "CPPFLAGS=${CPPFLAGS:?}"
        "CXX=${app['cxx']}"
        "LDFLAGS=${LDFLAGS:?}"
        'SYSTEM_HTSLIB=1'
        'VERBOSE=1'
    )
    if koopa_is_macos
    then
        # Static instead of dynamic build is currently recommended in README.
        # > make_args+=('STARforMac')
        make_args+=(
            # > "PKG_CONFIG=${app['pkg_config']} --static"
            'STARforMacStatic' 'STARlongForMacStatic'
        )
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
