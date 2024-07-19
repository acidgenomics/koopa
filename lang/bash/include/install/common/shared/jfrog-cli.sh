#!/usr/bin/env bash

main() {
    # """
    # Install JFrog CLI.
    # @note Updated 2024-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jfrog-cli
    # """
    local -A dict
    dict['bin_name']='jf'
    dict['ldflags']='-s -w'
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/jfrog/jfrog-cli/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_build_go_package \
        --bin-name="${dict['bin_name']}" \
        --ldflags="${dict['ldflags']}" \
        --url="${dict['url']}"
    return 0
}
