#!/usr/bin/env bash

install_node() { # {{{1
    # """
    # Install Node.js.
    # @note Updated 2022-03-28.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
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
        '--shared-brotli'
        '--shared-cares'
        '--shared-libuv'
        '--shared-nghttp2'
        '--shared-openssl'
        '--shared-zlib'
        '--with-intl=system-icu'
        '--without-corepack'
        '--without-npm'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
