#!/usr/bin/env bash

main() {
    # """
    # Install libgit2.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://libgit2.org/docs/guides/build-and-link/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgit2.rb
    # - https://github.com/libgit2/libgit2/blob/main/CMakeLists.txt
    # - https://github.com/libgit2/libgit2/issues/5079
    # """
    local -A cmake dict
    local -a build_deps cmake_args deps
    build_deps=('cmake' 'pkg-config')
    deps=('zlib' 'pcre' 'openssl' 'libssh2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    dict['libssh2']="$(koopa_app_prefix 'libssh2')"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['pcre']="$(koopa_app_prefix 'pcre')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    cmake['libssh2_include_dir']="${dict['libssh2']}/include"
    cmake['libssh2_library']="${dict['libssh2']}/lib/\
libssh2.${dict['shared_ext']}"
    cmake['openssl_crypto_library']="${dict['openssl']}/lib/\
libcrypto.${dict['shared_ext']}"
    cmake['openssl_include_dir']="${dict['openssl']}/include"
    cmake['openssl_ssl_library']="${dict['openssl']}/lib/\
libssl.${dict['shared_ext']}"
    cmake['pcre_include_dir']="${dict['pcre']}/include"
    cmake['pcre_library']="${dict['pcre']}/lib/libpcre.${dict['shared_ext']}"
    cmake['zlib_include_dir']="${dict['zlib']}/include"
    cmake['zlib_library']="${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake['libssh2_include_dir']}" \
        "${cmake['openssl_include_dir']}" \
        "${cmake['pcre_include_dir']}" \
        "${cmake['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake['libssh2_library']}" \
        "${cmake['openssl_crypto_library']}" \
        "${cmake['openssl_ssl_library']}" \
        "${cmake['pcre_library']}" \
        "${cmake['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_TESTS=OFF'
        '-DUSE_HTTPS=ON'
        '-DUSE_SSH=ON'
        # Dependency paths -----------------------------------------------------
        "-DLIBSSH2_INCLUDE_DIR=${cmake['libssh2_include_dir']}"
        "-DLIBSSH2_LIBRARY=${cmake['libssh2_library']}"
        "-DOPENSSL_CRYPTO_LIBRARY=${cmake['openssl_crypto_library']}"
        "-DOPENSSL_INCLUDE_DIR=${cmake['openssl_include_dir']}"
        "-DOPENSSL_SSL_LIBRARY=${cmake['openssl_ssl_library']}"
        "-DPCRE_INCLUDE_DIR=${cmake['pcre_include_dir']}"
        "-DPCRE_LIBRARY=${cmake['pcre_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake['zlib_library']}"
    )
    dict['url']="https://github.com/libgit2/libgit2/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
