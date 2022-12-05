#!/usr/bin/env bash

main() {
    # """
    # Install Chemacs2.
    # @note Updated 2022-12-05.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/plexus/chemacs2.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
