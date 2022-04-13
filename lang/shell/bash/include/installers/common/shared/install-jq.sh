#!/usr/bin/env bash

main() { #{{{1
    # """
    # Install jq.
    # @note Updated 2022-04-13.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/jq.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'libtool' 'oniguruma'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='jq'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://github.com/stedolan/${dict[name]}/releases/\
download/${dict[name]}-${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        "--prefix=${dict[prefix]}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
        '--disable-maintainer-mode'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
