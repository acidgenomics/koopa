#!/usr/bin/env bash

# FIXME Can we link the libraries into 'tools/v8_gypfiles/libbrotlidec.1.dylib'
# for example? A bit hacky but it may work...

# FIXME The node GYP installer doesn't set LD_LIBRARY_PATH correctly.
# Now seeing this issue: Library not loaded: 'libbrotlidec.1.dylib'

# FIXME Need to figure out how to pass LD_LIBRARY_PATH correctly during
# build argh...
# dyld[4379]: Library not loaded: 'libbrotlidec.1.dylib'

# It appears to be hard coded against /usr/lib and /usr/local/lib...
#
#  Reason: tried: 'libbrotlidec.1.dylib' (no such file), '/usr/local/lib/libbrotlidec.1.dylib' (no such file), '/usr/lib/libbrotlidec.1.dylib' (no such file), '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20220819-161858-VrllNF5yx0/node-v16.17.0/tools/v8_gypfiles/libbrotlidec.1.dylib' (no such file), '/usr/local/lib/libbrotlidec.1.dylib' (no such file), '/usr/lib/libbrotlidec.1.dylib' (no such file)

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
    # @note Updated 2022-08-19.
    #
    # @seealso
    # - https://github.com/nodejs/node/blob/main/BUILDING.md
    # - https://github.com/nodejs/node/blob/main/doc/contributing/
    #     building-node-with-ninja.md
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args deps dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config' 'ninja'
    deps=(
        'zlib'
        'icu4c'
        'libuv'
        'python'
        'openssl3'
        'c-ares'
        'brotli'
        'nghttp2'
        'ca-certificates'
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
        [ca_certificates]="$(koopa_app_prefix 'ca-certificates')"
        [brotli]="$(koopa_app_prefix 'brotli')"
        [cares]="$(koopa_app_prefix 'c-ares')"
        [jobs]="$(koopa_cpu_count)"
        [libuv]="$(koopa_app_prefix 'libuv')"
        [name]='node'
        [nghttp2]="$(koopa_app_prefix 'nghttp2')"
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
    koopa_alert_coffee_time
    dict[tmp_ld_target]='tools/v8_gypfiles'
    koopa_assert_is_dir "${dict[tmp_ld_target]}"
    dict[opt_prefix]="$(koopa_opt_prefix)"
    for dep in "${deps[@]}"
    do
        local files
        libdir="${dict[opt_prefix]}/${dep}/lib"
        [[ -d "$libdir" ]] || continue
        libdir="$(koopa_realpath "$libdir")"
        readarray -t files <<< "$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="$libdir" \
                --type='f' \
        )"
        if koopa_is_array_non_empty "${files[@]}"
        then
            koopa_ln \
                --target-directory="$PWD" \
                "${files[@]}"
            koopa_ln \
                --target-directory="${dict[tmp_ld_target]}" \
                "${files[@]}"
        fi
        readarray -t links <<< "$( \
            koopa_find \
                --max-depth=1 \
                --min-depth=1 \
                --prefix="$libdir" \
                --type='l' \
        )"
        if koopa_is_array_non_empty "${links[@]}"
        then
            koopa_ln \
                --target-directory="$PWD" \
                "${links[@]}"
            koopa_ln \
                --target-directory="${dict[tmp_ld_target]}" \
                "${links[@]}"
        fi
    done
    export PYTHON="${app[python]}"
    conf_args=(
        # > '--enable-lto'
        '--ninja'
        "--prefix=${dict[prefix]}"
        '--shared-brotli'
        "--shared-brotli-includes=${dict[brotli]}/include"
        "--shared-brotli-libpath=${dict[brotli]}/lib"
        '--shared-cares'
        "--shared-cares-includes=${dict[cares]}/include"
        "--shared-cares-libpath=${dict[cares]}/lib"
        '--shared-libuv'
        "--shared-libuv-includes=${dict[libuv]}/include"
        "--shared-libuv-libpath=${dict[libuv]}/lib"
        '--shared-nghttp2'
        "--shared-nghttp2-includes=${dict[nghttp2]}/include"
        "--shared-nghttp2-libpath=${dict[nghttp2]}/lib"
        '--shared-openssl'
        "--shared-openssl-includes=${dict[openssl]}/include"
        "--shared-openssl-libpath=${dict[openssl]}/lib"
        '--shared-zlib'
        "--shared-zlib-includes=${dict[zlib]}/include"
        "--shared-zlib-libpath=${dict[zlib]}/lib"
        '--with-intl=system-icu'
        '--without-corepack'
        "--openssl-system-ca-path=${dict[cacerts]}"
        '--openssl-use-def-ca-store'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
