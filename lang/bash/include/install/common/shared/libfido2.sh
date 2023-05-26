#!/usr/bin/env bash

# FIXME Need to add libcbor support.

#-- Checking for one of the modules 'libcbor'
#-- Checking for one of the modules 'libcrypto'
#-- Checking for one of the modules 'zlib'
#CMake Error at CMakeLists.txt:226 (message):
#  could not find libcbor

main() {
    # """
    # Install libfido2.
    # @note Updated 2023-05-26.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/libfido2
    # """
    local -A cmake dict
    local -a cmake_args
    koopa_activate_app --build-only 'pkg-config'
    koopa_activate_app 'libcbor' 'openssl3' 'zlib'
    dict['cbor']="$(koopa_app_prefix 'libcbor')"
    dict['openssl3']="$(koopa_app_prefix 'openssl3')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['url']="https://github.com/Yubico/libfido2/archive/\
${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    cmake['cbor_include_dir']="${dict['cbor']}/include"
    cmake['cbor_libraries']="${dict['cbor']}/lib/libcbor.${dict['shared_ext']}"
    cmake['openssl_root_dir']="${dict['openssl3']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['cbor_include_dir']}" \
        "${cmake['openssl_root_dir']}" \
        "${cmake['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake['cbor_libraries']}" \
        "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_STATIC_LIBS=OFF'
        # Dependency paths -----------------------------------------------------
        "-DCBOR_INCLUDE_DIR=${cmake['cbor_include_dir']}"
        "-DCBOR_LIBRARIES=${cmake['cbor_libraries']}"
        "-DOPENSSL_ROOT_DIR=${cmake['openssl_root_dir']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
