#!/usr/bin/env bash

# NOTE Consider tightening config for arpack, openblas, and superlu.

main() {
    # """
    # Install Armadillo.
    # @note Updated 2022-09-09.
    #
    # @seealso
    # - http://arma.sourceforge.net/download.html
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/armadillo.rb
    # - https://git.alpinelinux.org/aports/tree/community/armadillo/APKBUILD
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'cmake' 'pkg-config'
    koopa_activate_opt_prefix 'hdf5'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['name']='armadillo'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['name']}-${dict['version']}.tar.xz"
    dict['url']="http://sourceforge.net/projects/arma/files/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        # > '-DCMAKE_BUILD_TYPE=MinSizeRel'
        # > '-DCMAKE_INSTALL_LIBDIR=lib'
        "-DCMAKE_INSTALL_PREFIX:PATH=${dict['prefix']}"
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DDETECT_HDF5=ON'
    )
    if koopa_is_macos
    then
        cmake_args+=('-DALLOW_OPENBLAS_MACOS=ON')
    fi
    "${app['cmake']}" -B 'build' "${cmake_args[@]}"
    "${app['cmake']}" --build 'build'
    "${app['cmake']}" --install 'build'
    return 0
}
