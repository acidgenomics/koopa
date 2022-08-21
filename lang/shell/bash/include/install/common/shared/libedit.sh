#!/usr/bin/env bash

main() {
    # """
    # Install libedit.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://thrysoee.dk/editline/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/libedit.rb
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix 'pkg-config'
    koopa_activate_opt_prefix 'ncurses'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || return 1
    declare -A dict=(
        [name]='libedit'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict['name']}-${dict['version']}.tar.gz"
    dict[url]="https://thrysoee.dk/editline/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    conf_args=(
        "--prefix=${dict['prefix']}"
        '--disable-dependency-tracking'
        '--disable-silent-rules'
    )
    ./configure --help
    ./configure "${conf_args[@]}"
    "${app['make']}" install
    return 0
}
