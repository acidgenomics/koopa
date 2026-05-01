#!/usr/bin/env bash

install_from_conda() {
    _koopa_install_conda_package
    return 0
}

install_from_source() {
    # """
    # Install kallisto from source.
    # @note updated 2026-03-21.
    #
    # @seealso
    # - https://github.com/pachterlab/kallisto
    # - https://github.com/bioconda/bioconda-recipes/tree/master/
    #     recipes/kallisto
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     kallisto.rb
    # - https://github.com/pachterlab/kallisto/issues/159
    # - https://github.com/pachterlab/kallisto/issues/160
    # - https://github.com/pachterlab/kallisto/issues/161
    # - https://github.com/pachterlab/kallisto/issues/303
    # - https://github.com/pachterlab/kallisto/issues/385
    # """
    local -A app cmake dict
    local -a build_deps cmake_args deps
    build_deps=('autoconf' 'automake' 'patch')
    deps=(
        'bzip2'
        'xz'
        'zlib'
        'libaec' # hdf5
        'hdf5'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_activate_app "${deps[@]}"
    app['autoreconf']="$(_koopa_locate_autoreconf)"
    app['patch']="$(_koopa_locate_patch)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bzip2']="$(_koopa_app_prefix 'bzip2')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(_koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(_koopa_app_prefix 'zlib')"
    cmake['bzip2_include_dir']="${dict['bzip2']}/include"
    cmake['bzip2_libraries']="${dict['bzip2']}/lib/libbz2.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    _koopa_assert_is_dir \
        "${cmake['bzip2_include_dir']}" \
        "${cmake['zlib_include_dir']}"
    _koopa_assert_is_file \
        "${cmake['bzip2_libraries']}" \
        "${cmake['zlib_library']}"
    cmake_args=(
        # CMake options --------------------------------------------------------
        '-DCMAKE_POLICY_VERSION_MINIMUM=3.5'
        # Build options --------------------------------------------------------
        '-DCOMPILATION_ARCH=OFF'
        '-DENABLE_AVX2=OFF'
        '-DUSE_BAM=OFF'
        '-DUSE_HDF5=OFF'
        # Dependency paths -----------------------------------------------------
        "-DBZIP2_INCLUDE_DIR=${cmake['bzip2_include_dir']}"
        "-DBZIP2_LIBRARIES=${cmake['bzip2_libraries']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    dict['url']="https://github.com/pachterlab/kallisto/archive/refs/tags/\
v${dict['version']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    export CMAKE_POLICY_VERSION_MINIMUM=3.5
    export KOOPA_CPU_COUNT=1
    if _koopa_is_macos
    then
        app['patch']="$(_koopa_locate_patch)"
        _koopa_assert_is_executable "${app['patch']}"
        dict['patch_prefix']="$(_koopa_patch_prefix)/common/kallisto"
        _koopa_assert_is_dir "${dict['patch_prefix']}"
        dict['patch_file']="${dict['patch_prefix']}/2026-03-21-macos.patch"
        "${app['patch']}" -p1 < "${dict['patch_file']}"
    fi
    _koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}

main() {
    install_from_conda
    return 0
}
