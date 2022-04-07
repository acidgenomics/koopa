#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Node.js.
    # @note Updated 2022-04-07.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    if koopa_is_macos
    then
        koopa_activate_homebrew_opt_prefix \
            'brotli' \
            'c-ares' \
            'icu4c' \
            'libnghttp2' \
            'libuv' \
            'openssl@1.1' \
            'pkg-config' \
            'python@3'
    else
        koopa_activate_opt_prefix \
            'icu4c' \
            'pkg-config' \
            'python'
    fi
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="node-v${dict[version]}.tar.xz"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "node-v${dict[version]}"
    koopa_alert_coffee_time
    conf_args=(
        "--prefix=${dict[prefix]}"
        # > '--without-corepack'
        # > '--without-npm'
    )
    if koopa_is_macos
    then
        conf_args+=(
            '--shared-brotli'
            '--shared-cares'
            '--shared-libuv'
            '--shared-nghttp2'
            '--shared-openssl'
            '--shared-zlib'
            '--with-intl=system-icu'
        )
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
