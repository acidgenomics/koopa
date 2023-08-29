#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/mikefarah/yq/archive/\
v${dict['version']}.tar.gz"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='yq' \
        -D "--url=${dict['url']}"
    return 0
}
