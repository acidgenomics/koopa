#!/usr/bin/env bash

main() {
    # """
    # Install Node.js.
    # @note Updated 2022-09-28.
    #
    # Inclusion of shared brotli currently causes the installer to error.
    #
    # @seealso
    # - https://github.com/nodejs/node/blob/main/BUILDING.md
    # - https://github.com/nodejs/node/blob/main/doc/contributing/
    #     building-node-with-ninja.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # - https://code.google.com/p/v8/wiki/BuildingWithGYP
    # - https://chromium.googlesource.com/external/github.com/v8/v8.wiki/+/
    #     c62669e6c70cc82c55ced64faf44804bd28f33d5/Building-with-Gyp.md
    # - https://v8.dev/docs/build-gn
    # - https://code.google.com/archive/p/pyv8/
    # - https://stackoverflow.com/questions/29773160/
    # - https://stackoverflow.com/questions/16215082/
    # - https://bugs.chromium.org/p/gyp/adminIntro
    # - https://github.com/nodejs/node-gyp
    # - https://github.com/conda-forge/nodejs-feedstock/blob/main/
    #     recipe/build.sh
    # - https://github.com/nodejs/gyp-next/actions/runs/711098809/workflow
    # """
    local app build_deps conf_args deps dict
    koopa_assert_has_no_args "$#"
    build_deps=(
        'pkg-config'
        'ninja'
    )
    deps=(
        'ca-certificates'
        'zlib'
        # > 'bzip2'
        'icu4c'
        'libuv'
        'openssl3'
        'python'
        'c-ares'
        'nghttp2'
        # > 'brotli'
    )
    koopa_activate_app --build-only "${build_deps[@]}"
    koopa_activate_app "${deps[@]}"
    declare -A app=(
        ['make']="$(koopa_locate_make)"
        ['python']="$(koopa_locate_python --realpath)"
    )
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['python']}" ]] || return 1
    declare -A dict=(
        # > [brotli]="$(koopa_app_prefix 'brotli')"
        ['ca_certificates']="$(koopa_app_prefix 'ca-certificates')"
        ['cares']="$(koopa_app_prefix 'c-ares')"
        ['jobs']="$(koopa_cpu_count)"
        ['libuv']="$(koopa_app_prefix 'libuv')"
        ['name']='node'
        ['nghttp2']="$(koopa_app_prefix 'nghttp2')"
        ['openssl']="$(koopa_app_prefix 'openssl3')"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
        ['zlib']="$(koopa_app_prefix 'zlib')"
    )
    dict['cacerts']="${dict['ca_certificates']}/share/ca-certificates/\
cacert.pem"
    koopa_assert_is_file "${dict['cacerts']}"
    dict['file']="${dict['name']}-v${dict['version']}.tar.xz"
    dict['url']="https://nodejs.org/dist/v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-v${dict['version']}"
    export LDFLAGS_host="${LDFLAGS:?}"
    export PYTHON="${app['python']}"
    # conda-forge currently uses shared libuv, openssl, and zlib, but not
    # brotli, c-cares, and nghttp2.
    conf_args=(
        # > '--cross-compiling'
        # > '--enable-lto'
        # > '--error-on-warn'
        "--prefix=${dict['prefix']}"
        '--ninja'
        "--openssl-system-ca-path=${dict['cacerts']}"
        '--openssl-use-def-ca-store'
        '--shared'
        # > '--shared-brotli'
        # > "--shared-brotli-includes=${dict['brotli']}/include"
        # > "--shared-brotli-libpath=${dict['brotli']}/lib"
        '--shared-cares'
        "--shared-cares-includes=${dict['cares']}/include"
        "--shared-cares-libpath=${dict['cares']}/lib"
        '--shared-libuv'
        "--shared-libuv-includes=${dict['libuv']}/include"
        "--shared-libuv-libpath=${dict['libuv']}/lib"
        '--shared-nghttp2'
        "--shared-nghttp2-includes=${dict['nghttp2']}/include"
        "--shared-nghttp2-libpath=${dict['nghttp2']}/lib"
        '--shared-openssl'
        "--shared-openssl-includes=${dict['openssl']}/include"
        "--shared-openssl-libpath=${dict['openssl']}/lib"
        '--shared-zlib'
        "--shared-zlib-includes=${dict['zlib']}/include"
        "--shared-zlib-libpath=${dict['zlib']}/lib"
        '--with-intl=system-icu'
        '--without-corepack'
        '--without-node-snapshot'
        '--verbose'
    )
    # This is needed to put sysctl into PATH.
    koopa_is_macos && koopa_add_to_path_end '/usr/sbin'
    koopa_print_env
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" --jobs="${dict['jobs']}"
    # Need to fix installer path for 'libnode.so.93' on Ubuntu 22.
    # https://github.com/nodejs/node/issues/30111
    if koopa_is_linux && [[ -f 'out/Release/lib/libnode.so.93' ]]
    then
        (
            koopa_cd 'out/Release'
            koopa_ln 'lib/libnode.so.93' 'libnode.so.93'
        )
    fi
    "${app['make']}" install
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln \
            ../../../'lib/node_modules/npm/man/man1/npm.1' \
            'npm.1'
        koopa_ln \
            ../../../'lib/node_modules/npm/man/man1/npx.1' \
            'npx.1'
    )
    return 0
}
