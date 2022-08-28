#!/usr/bin/env bash

main() {
    # """
    # Install Chemacs2.
    # @note Updated 2022-07-14.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['commit']="${INSTALL_VERSION:?}"
        ['prefix']="${INSTALL_PREFIX:?}"
        ['url']='https://github.com/plexus/chemacs2.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    koopa_configure_chemacs "${dict['prefix']}"
    return 0
}
