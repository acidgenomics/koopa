#!/usr/bin/env bash

main() {
    # """
    # Install rbenv.
    # @note Updated 2023-06-02.
    #
    # @seealso
    # - https://github.com/rbenv/rbenv
    # - https://github.com/rbenv/ruby-build
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/rbenv/rbenv/archive/refs/tags/\
v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract \
        "$(koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    koopa_git_clone \
        --prefix="${dict['prefix']}/plugins/ruby-build" \
        --tag='v20220713' \
        --url='https://github.com/rbenv/ruby-build.git'
    return 0
}
