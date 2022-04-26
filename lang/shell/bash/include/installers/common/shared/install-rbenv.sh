#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2022-04-26.
    #
    # @seealso
    # - https://github.com/rbenv/rbenv
    # - https://github.com/rbenv/ruby-build
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='rbenv'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="v${dict[version]}.tar.gz"
    dict[url]="https://github.com/${dict[name]}/${dict[name]}/archive/\
refs/tags/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cp "${dict[name]}-${dict[version]}" "${dict[prefix]}"
    koopa_mkdir "${dict[prefix]}/plugins"
    # NOTE Consider also versioning 'ruby-build' here.
    koopa_git_clone \
        'https://github.com/rbenv/ruby-build.git' \
        "${dict[prefix]}/plugins/ruby-build"
    return 0
}
