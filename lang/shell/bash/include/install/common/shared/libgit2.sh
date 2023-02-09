#!/usr/bin/env bash

# FIXME Still seeing an openssl header linkage issue with 1.5.1 on Ubuntu.
#
# /tmp/koopa-1000-20230209-120524-dBwL22zWjB/libgit2-1.5.1/src/util/hash/openssl.h:14:11: fatal error: openssl/sha.h: No such file or directory
#   14 | # include <openssl/sha.h>
#      |           ^~~~~~~~~~~~~~~
# compilation terminated.
# gmake[2]: *** [src/cli/CMakeFiles/git2_cli.dir/build.make:118: src/cli/CMakeFiles/git2_cli.dir/cmd_hash_object.c.o] Error 1
# gmake[2]: *** Waiting for unfinished jobs....
# gmake[2]: *** [src/cli/CMakeFiles/git2_cli.dir/build.make:104: src/cli/CMakeFiles/git2_cli.dir/cmd_clone.c.o] Error 1
# [ 98%] Built target libgit2package
# gmake[1]: *** [CMakeFiles/Makefile2:323: src/cli/CMakeFiles/git2_cli.dir/all] Error 2
# gmake: *** [Makefile:136: all] Error 2

main() {
    # """
    # Install libgit2.
    # @note Updated 2023-02-09.
    #
    # @seealso
    # - https://libgit2.org/docs/guides/build-and-link/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libgit2.rb
    # - https://github.com/libgit2/libgit2/blob/main/CMakeLists.txt
    # - https://github.com/libgit2/libgit2/issues/5079
    # """
    local app cmake_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only \
        'cmake' \
        'pkg-config'
    koopa_activate_app \
        'zlib' \
        'pcre' \
        'openssl3' \
        'libssh2'
    declare -A app=(
        ['cmake']="$(koopa_locate_cmake)"
    )
    [[ -x "${app['cmake']}" ]] || return 1
    declare -A dict=(
        ['jobs']="$(koopa_cpu_count)"
        ['name']='libgit2'
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['pcre']="$(koopa_app_prefix 'pcre')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['shared_ext']="$(koopa_shared_ext)"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    koopa_assert_is_dir \
        "${dict['openssl']}" \
        "${dict['pcre']}" \
        "${dict['zlib']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/${dict['name']}/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    cmake_args=(
        '-DBUILD_TESTS=OFF'
        '-DCMAKE_BUILD_TYPE=Release'
        "-DCMAKE_CXX_FLAGS=${CPPFLAGS:-}"
        "-DCMAKE_C_FLAGS=${CFLAGS:-}"
        "-DCMAKE_EXE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_INSTALL_PREFIX=${dict['prefix']}"
        "-DCMAKE_INSTALL_RPATH=${dict['openssl']}/lib"
        "-DCMAKE_MODULE_LINKER_FLAGS=${LDFLAGS:-}"
        "-DCMAKE_SHARED_LINKER_FLAGS=${LDFLAGS:-}"
        '-DUSE_BUNDLED_ZLIB=OFF'
        '-DUSE_SSH=YES'
        "-DOPENSSL_ROOT_DIR=${dict['openssl']}"
        "-DPCRE_INCLUDE_DIR=${dict['pcre']}/include"
        "-DPCRE_LIBRARY=${dict['pcre']}/lib/libpcre.${dict['shared_ext']}"
        "-DZLIB_INCLUDE_DIR=${dict['zlib']}/include"
        "-DZLIB_LIBRARY=${dict['zlib']}/lib/libz.${dict['shared_ext']}"
    )
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
