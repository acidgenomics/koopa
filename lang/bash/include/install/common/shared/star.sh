#!/usr/bin/env bash

# FIXME zlib linkage isn't correct with current Makefile:
# https://github.com/alexdobin/STAR/blob/master/source/htslib/Makefile

main() {
    # """
    # Install STAR.
    # @note Updated 2023-08-22.
    #
    # @seealso
    # - https://github.com/alexdobin/STAR/
    # - https://github.com/bioconda/bioconda-recipes/tree/master/recipes/star
    # - https://github.com/alexdobin/STAR/issues/1265
    # """
    local -A app
    local -a make_args
    koopa_activate_app --build-only 'coreutils' 'gcc' 'make'
    koopa_activate_app 'zlib'
    app['autoreconf']="$(koopa_locate_autoreconf)"
    app['date']="$(koopa_locate_date)"
    app['gcxx']="$(koopa_locate_gcxx)"
    app['make']="$(koopa_locate_make)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/alexdobin/STAR/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    # Need to correct htslib Makefile for zlib.
    dict['cram_src']="$(koopa_realpath 'src/source/htslib/cram')"
    dict['htslib_src']="$(koopa_realpath 'src/source/htslib/htslib')"
    CPPFLAGS="${CPPFLAGS:-} -I. -I./cram -I./htslib"
    export CPPFLAGS
    koopa_find_and_replace_in_file \
        --pattern='^LDFLAGS  =$' \
        --regex \
        --replacement="LDFLAGS := ${LDFLAGS:?}" \
        'src/source/htslib/Makefile'
    koopa_find_and_replace_in_file \
        --pattern='^LDLIBS   =$' \
        --regex \
        --replacement="LDLIBS := ${LDLIBS:?}" \
        'src/source/htslib/Makefile'
    koopa_cd 'src/source'
    make_args+=(
        "--jobs=${dict['jobs']}"
        "CPPFLAGS=${CPPFLAGS:?}"
        "CXX=${app['gcxx']}"
        "LDFLAGS=${LDFLAGS:?}"
        "LDLIBS=${LDLIBS:?}"
        'VERBOSE=1'
    )
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
