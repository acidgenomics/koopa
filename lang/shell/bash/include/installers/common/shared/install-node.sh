#!/usr/bin/env bash

main() {
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
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'icu4c' 'python'
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
    conf_args=("--prefix=${dict[prefix]}")
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    return 0
}
