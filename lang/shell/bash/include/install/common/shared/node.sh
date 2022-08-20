#!/usr/bin/env bash

# FIXME Cryptic yarn (node package) registry error when attempting to build
# coc.nvim dependencies in ~/.vim/plugged/coc.nvim:
# 
# # 'yarn registry error incorrect data check'
#
# This is likely due to some OpenSSL issue, so rebuild Node.js with better
# linkage, and see if that resolves.



main() {
    # """
    # Install Node.js.
    # @note Updated 2022-08-20.
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
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config' 'ninja'
    deps=(
        'ca-certificates'
        'zlib'
        'icu4c'
        'libuv'
        'openssl3'
        'python'
        # > 'brotli'
        # > 'c-ares'
        # > 'nghttp2'
    )
    koopa_activate_opt_prefix "${deps[@]}"
    declare -A app=(
        [make]="$(koopa_locate_make)"
        [python]="$(koopa_locate_python)"
    )
    [[ -x "${app[make]}" ]] || return 1
    [[ -x "${app[python]}" ]] || return 1
    app[python]="$(koopa_realpath "${app[python]}")"
    declare -A dict=(
        # > [brotli]="$(koopa_app_prefix 'brotli')"
        [ca_certificates]="$(koopa_app_prefix 'ca-certificates')"
        # > [cares]="$(koopa_app_prefix 'c-ares')"
        [jobs]="$(koopa_cpu_count)"
        [libuv]="$(koopa_app_prefix 'libuv')"
        [name]='node'
        # > [nghttp2]="$(koopa_app_prefix 'nghttp2')"
        [openssl]="$(koopa_app_prefix 'openssl3')"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [zlib]="$(koopa_app_prefix 'zlib')"
    )
    dict[cacerts]="${dict[ca_certificates]}/share/ca-certificates/cacert.pem"
    koopa_assert_is_file "${dict[cacerts]}"
    dict[file]="${dict[name]}-v${dict[version]}.tar.xz"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-v${dict[version]}"
    export LDFLAGS_host="${LDFLAGS:?}"
    export PYTHON="${app[python]}"
    # conda-forge currently uses shared libuv, openssl, and zlib, but not
    # brotli, c-cares, and nghttp2.
    conf_args=(
        # > '--cross-compiling'
        # > '--enable-lto'
        # > '--error-on-warn'
        "--prefix=${dict[prefix]}"
        '--ninja'
        "--openssl-system-ca-path=${dict[cacerts]}"
        '--openssl-use-def-ca-store'
        '--shared'
        # > '--shared-brotli'
        # > "--shared-brotli-includes=${dict[brotli]}/include"
        # > "--shared-brotli-libpath=${dict[brotli]}/lib"
        # > '--shared-cares'
        # > "--shared-cares-includes=${dict[cares]}/include"
        # > "--shared-cares-libpath=${dict[cares]}/lib"
        '--shared-libuv'
        "--shared-libuv-includes=${dict[libuv]}/include"
        "--shared-libuv-libpath=${dict[libuv]}/lib"
        # > '--shared-nghttp2'
        # > "--shared-nghttp2-includes=${dict[nghttp2]}/include"
        # > "--shared-nghttp2-libpath=${dict[nghttp2]}/lib"
        '--shared-openssl'
        "--shared-openssl-includes=${dict[openssl]}/include"
        "--shared-openssl-libpath=${dict[openssl]}/lib"
        '--shared-zlib'
        "--shared-zlib-includes=${dict[zlib]}/include"
        "--shared-zlib-libpath=${dict[zlib]}/lib"
        '--with-intl=system-icu'
        '--without-corepack'
        '--without-node-snapshot'
        '--verbose'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
