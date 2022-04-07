#!/usr/bin/env bash

install_rbenv() { # {{{1
    # """
    # Install rbenv.
    # @note Updated 2021-11-24.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url1]='https://github.com/sstephenson/rbenv.git'
        [url2]='https://github.com/sstephenson/ruby-build.git'
    )
    koopa_git_clone "${dict[url1]}" "${dict[prefix]}"
    koopa_mkdir "${dict[prefix]}/plugins"
    koopa_git_clone "${dict[url2]}" "${dict[prefix]}/plugins/ruby-build"
    return 0
}
