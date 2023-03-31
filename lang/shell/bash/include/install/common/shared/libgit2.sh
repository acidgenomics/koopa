#!/usr/bin/env bash

main() {
    # """
    # Install libgit2.
    # @note Updated 2023-03-31.
    #
    # @seealso
    # - https://libgit2.org/docs/guides/build-and-link/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgit2.rb
    # - https://github.com/libgit2/libgit2/blob/main/CMakeLists.txt
    # - https://github.com/libgit2/libgit2/issues/5079
    # """
    local build_deps cmake_args deps dict
    declare -A cmake_dict dict
    koopa_assert_has_no_args "$#"
    build_deps=('cmake' 'pkg-config')
    deps=('zlib' 'pcre')
    koopa_is_macos && deps+=('openssl3' 'libssh2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A dict=(
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    if koopa_is_macos
    then
        dict['openssl']="$(koopa_app_prefix 'openssl3')"
    fi
    cmake_dict['pcre_include_dir']="${dict['pcre']}/include"
    cmake_dict['pcre_library']="${dict['pcre']}/lib/\
libpcre.${dict['shared_ext']}"
    cmake_dict['zlib_include_dir']="${dict['zlib']}/include"
    cmake_dict['zlib_library']="${dict['zlib']}/lib/\
libz.${dict['shared_ext']}"
    koopa_assert_is_dir \
        "${cmake_dict['pcre_include_dir']}" \
        "${cmake_dict['zlib_include_dir']}"
    koopa_assert_is_file \
        "${cmake_dict['pcre_library']}" \
        "${cmake_dict['zlib_library']}"
    cmake_args=(
        # Build options --------------------------------------------------------
        '-DBUILD_TESTS=OFF'
        # Dependency paths -----------------------------------------------------
        "-DPCRE_INCLUDE_DIR=${cmake_dict['pcre_include_dir']}"
        "-DPCRE_LIBRARY=${cmake_dict['pcre_library']}"
        "-DZLIB_INCLUDE_DIR=${cmake_dict['zlib_include_dir']}"
        "-DZLIB_LIBRARY=${cmake_dict['zlib_library']}"
    )
    if koopa_is_macos
    then
        cmake_dict['openssl_crypto_library']="${dict['openssl']}/lib/\
libcrypto.${dict['shared_ext']}"
        cmake_dict['openssl_include_dir']="${dict['openssl']}/include"
        cmake_dict['openssl_ssl_library']="${dict['openssl']}/lib/\
libssl.${dict['shared_ext']}"
        koopa_assert_is_dir \
            "${cmake_dict['openssl_include_dir']}"
        koopa_assert_is_file \
            "${cmake_dict['openssl_crypto_library']}" \
            "${cmake_dict['openssl_ssl_library']}"
        cmake_args+=(
            # Build options ----------------------------------------------------
            '-DUSE_HTTPS=ON'
            '-DUSE_SSH=ON'
            # Dependency paths -------------------------------------------------
            "-DOPENSSL_CRYPTO_LIBRARY=${cmake_dict['openssl_crypto_library']}"
            "-DOPENSSL_INCLUDE_DIR=${cmake_dict['openssl_include_dir']}"
            "-DOPENSSL_SSL_LIBRARY=${cmake_dict['openssl_ssl_library']}"
        )
    else
        cmake_args+=(
            '-DUSE_HTTPS=OFF'
            '-DUSE_SSH=OFF'
        )
    fi
    dict['url']="https://github.com/libgit2/libgit2/archive/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_cmake_build --prefix="${dict['prefix']}" "${cmake_args[@]}"
    return 0
}
