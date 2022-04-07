#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install CloudBioLinux.
    # @note Updated 2021-11-16.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/chapmanb/cloudbiolinux.git'
    )
    koopa_git_clone "${dict[url]}" "${dict[prefix]}"
}
