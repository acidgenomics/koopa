#!/usr/bin/env bash

# NOTE Consider using bundled openssl with:
# --shared-openssl=no

main() {
    # """
    # Install Node.js.
    # @note Updated 2025-08-21.
    #
    # Corepack configuration gets saved to '~/.cache/node/corepack'.
    #
    # Inclusion of shared brotli currently causes the installer to error.
    #
    # conda-forge currently uses shared libuv, openssl, and zlib, but not
    # brotli, c-cares, and nghttp2.
    #
    # @seealso
    # - https://github.com/nodejs/release#release-schedule
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
    # - https://github.com/nodejs/corepack
    # - https://www.linuxfromscratch.org/blfs/view/svn/general/nodejs.html
    # """
    local -A app dict
    local -a build_deps conf_args deps
    build_deps=('make' 'ninja' 'pkg-config')
    # > deps=(
    # >     'ca-certificates'
    # >     'zlib'
    # >     'icu4c'
    # >     'libuv'
    # >     'openssl'
    # >     'python'
    # >     'c-ares'
    # >     # Hitting an nghttp2 build issue on Ubuntu 22, so disabling here.
    # >     # > 'nghttp2'
    # > )
    koopa_activate_app --build-only "${build_deps[@]}"
    # > koopa_activate_app "${deps[@]}"
    app['make']="$(koopa_locate_make)"
    app['python']="$(koopa_locate_python --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['ca_certificates']="$(koopa_app_prefix 'ca-certificates')"
    dict['cares']="$(koopa_app_prefix 'c-ares')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['libuv']="$(koopa_app_prefix 'libuv')"
    # > dict['nghttp2']="$(koopa_app_prefix 'nghttp2')"
    dict['openssl']="$(koopa_app_prefix 'openssl')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['shared_ext']="$(koopa_shared_ext)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['zlib']="$(koopa_app_prefix 'zlib')"
    dict['cacerts']="${dict['ca_certificates']}/share/ca-certificates/\
cacert.pem"
    koopa_assert_is_file "${dict['cacerts']}"
    conf_args=(
        '--ninja'
        # > "--openssl-system-ca-path=${dict['cacerts']}"
        # > '--openssl-use-def-ca-store'
        "--prefix=${dict['prefix']}"
        # > '--shared'
        # > '--shared-cares'
        # > "--shared-cares-includes=${dict['cares']}/include"
        # > "--shared-cares-libpath=${dict['cares']}/lib"
        # > '--shared-libuv'
        # > "--shared-libuv-includes=${dict['libuv']}/include"
        # > "--shared-libuv-libpath=${dict['libuv']}/lib"
        # > '--shared-nghttp2'
        # > "--shared-nghttp2-includes=${dict['nghttp2']}/include"
        # > "--shared-nghttp2-libpath=${dict['nghttp2']}/lib"
        # > '--shared-openssl'
        # > "--shared-openssl-includes=${dict['openssl']}/include"
        # > "--shared-openssl-libpath=${dict['openssl']}/lib"
        # > '--shared-zlib'
        # > "--shared-zlib-includes=${dict['zlib']}/include"
        # > "--shared-zlib-libpath=${dict['zlib']}/lib"
        # > '--with-intl=system-icu'
        # > '--without-node-snapshot'
        '--verbose'
    )
    if [[ -n "${LDFLAGS:-}" ]]
    then
        export LDFLAGS_host="${LDFLAGS:?}"
    fi
    export PYTHON="${app['python']}"
    # This is needed to put sysctl into PATH.
    koopa_is_macos && koopa_add_to_path_end '/usr/sbin'
    dict['url']="https://nodejs.org/dist/v${dict['version']}/\
node-v${dict['version']}.tar.xz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    # Need to fix installer path for 'libnode.so' on Ubuntu 22.
    # https://github.com/nodejs/node/issues/30111
    if koopa_is_linux
    then
        dict['libnode_file']="$( \
            koopa_find \
                --exclude='*.TOC' \
                --max-depth=1 \
                --min-depth=1 \
                --pattern="libnode.${dict['shared_ext']}.*" \
                --prefix='out/Release/lib' \
                --type='f' \
        )"
        dict['libnode_bn']="$(koopa_basename "${dict['libnode_file']}")"
        (
            koopa_cd 'out/Release'
            koopa_ln "lib/${dict['libnode_bn']}" "${dict['libnode_bn']}"
        )
    fi
    "${app['make']}" install
    (
        koopa_cd "${dict['prefix']}/bin"
        koopa_ln \
            '../lib/node_modules/corepack/dist/yarn.js' \
            'yarn'
    )
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln \
            '../../../lib/node_modules/npm/man/man1/npm.1' \
            'npm.1'
        koopa_ln \
            '../../../lib/node_modules/npm/man/man1/npx.1' \
            'npx.1'
    )
    return 0
}
