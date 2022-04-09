#!/usr/bin/env bash

# FIXME May need to configure these on macOS:
#'brotli' \
#'c-ares' \
#'icu4c' \
#'libnghttp2' \
#'libuv' \
#'openssl@1.1' \
#'pkg-config' \
#'python@3'

main() { # {{{1
    # """
    # Install Node.js.
    # @note Updated 2022-04-08.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/node.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'icu4c' 'pkg-config' 'python'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='node'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-v${dict[version]}.tar.xz"
    dict[url]="https://nodejs.org/dist/v${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-v${dict[version]}"
    koopa_alert_coffee_time
    conf_args=(
        "--prefix=${dict[prefix]}"
    )
    # > if koopa_is_macos
    # > then
    # >     conf_args+=(
    # >         '--shared-brotli'
    # >         '--shared-cares'
    # >         '--shared-libuv'
    # >         '--shared-nghttp2'
    # >         '--shared-openssl'
    # >         '--shared-zlib'
    # >         '--with-intl=system-icu'
    # >     )
    # > fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
