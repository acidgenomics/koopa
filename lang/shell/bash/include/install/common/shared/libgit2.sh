#!/usr/bin/env bash

main() {
    # """
    # Install libgit2.
    # @note Updated 2023-02-13.
    #
    # @seealso
    # - https://libgit2.org/docs/guides/build-and-link/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgit2.rb
    # - https://github.com/libgit2/libgit2/blob/main/CMakeLists.txt
    # - https://github.com/libgit2/libgit2/issues/5079
    # """
    local app build_deps cmake_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=('cmake' 'pkg-config')
    deps=('zlib' 'pcre')
    koopa_is_macos && deps+=('openssl3' 'libssh2')
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libgit2'
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    if koopa_is_macos
    then
        dict['libssh2']="$(koopa_app_prefix 'libssh2')"
        dict['openssl']="$(koopa_app_prefix 'openssl3')"
    fi
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        '-DBUILD_TESTS=OFF'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        "-DPCRE_INCLUDE_DIR=${dict['pcre']}/include"
        "-DPCRE_LIBRARY=${dict['pcre']}/lib/libpcre.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
    if koopa_is_macos
    then
        cmake_args+=(
            "-DCMAKE_INSTALL_RPATH=${dict['openssl']}/lib"
            '-DUSE_HTTPS=ON'
            '-DUSE_SSH=ON'
            "-DLIBSSH2_INCLUDE_DIR=${dict['libssh2']}/include"
            "-DLIBSSH2_LIBRARY=${dict['libssh2']}/lib/libssh2.${dict['shared_ext']}"
            # NOTE Use 'OPENSSL_LIBRARIES' here instead?
            "-DOPENSSL_CRYPTO_LIBRARY=${dict['openssl']}/lib/\
libcrypto.${dict['shared_ext']}"
            "-DOPENSSL_INCLUDE_DIR=${dict['openssl']}/include"
            "-DOPENSSL_SSL_LIBRARY=${dict['openssl']}/lib/\
libssl.${dict['shared_ext']}"
        )
    else
        cmake_args+=(
            '-DUSE_HTTPS=OFF'
            '-DUSE_SSH=OFF'
        )
    fi
    koopa_print_env
    koopa_dl 'CMake args' "${cmake_args[*]}"
    "${app['cmake']}" -LH \
        -S '.' \
        -B 'build' \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build 'build' \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" --install 'build'
    return 0
}
