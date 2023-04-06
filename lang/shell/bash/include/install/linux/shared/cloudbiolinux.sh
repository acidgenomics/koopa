#!/usr/bin/env bash

main() {
    # """
    # Install CloudBioLinux.
    # @note Updated 2023-04-06.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/chapmanb/cloudbiolinux.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    return 0
}
