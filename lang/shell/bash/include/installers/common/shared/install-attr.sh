#!/usr/bin/env bash

# NOTE This is currently failing to build on macOS.

main() { # {{{1
    # """
    # Install attr.
    # @note Updated 2022-04-10.
    #
    #
    # @seealso
    # - https://savannah.nongnu.org/projects/attr
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/attr.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    # > koopa_activate_opt_prefix 'gettext'
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='attr'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.gz"
    dict[url]="https://download.savannah.nongnu.org/releases/\
${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
           "--prefix=${dict[prefix]}"
           '--disable-debug'
           '--disable-dependency-tracking'
           '--disable-silent-rules'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}
