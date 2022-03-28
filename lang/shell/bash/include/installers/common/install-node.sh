#!/usr/bin/env bash

install_node() { # {{{1
    # """
    # Install Node.js.
    # @note Updated 2022-03-28.
    #
    # @seealso
    # - https://github.com/nodejs/node
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/nodejs/node/archive/refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "node-${dict[version]}"
    koopa_alert_coffee_time
    ./configure --prefix="${dict[prefix]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
