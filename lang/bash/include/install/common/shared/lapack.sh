#!/usr/bin/env bash

main() {
    # """
    # Install LAPACK.
    # @note Updated 2023-10-17.
    #
    # @seealso
    # - https://www.netlib.org/lapack/
    # - https://github.com/Reference-LAPACK/lapack
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/lapack.rb
    # """
    local -A app dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    if koopa_is_macos
    then
        app['fortran']='/opt/gfortran/bin/gfortran'
    else
        app['fortran']="$(koopa_locate_gfortran --only-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    # Temporary fix for 3.11.0 download link.
    case "${dict['version']}" in
        '3.11.0')
            dict['version']='3.11'
            ;;
    esac
    dict['url']="https://github.com/Reference-LAPACK/lapack/archive/refs/tags/\
v${dict['version']}.tar.gz"
    cmake_args=(
        '-DBUILD_SHARED_LIBS=ON'
        "-DCMAKE_Fortran_COMPILER=${app['fortran']}"
        '-DLAPACKE=ON'
    )
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
