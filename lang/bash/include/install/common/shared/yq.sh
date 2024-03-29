#!/usr/bin/env bash

main() {
    # """
    # Install yq.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/yq.rb
    # - go help build
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/mikefarah/yq/archive/\
v${dict['version']}.tar.gz"
    koopa_build_go_package --url="${dict['url']}"
    return 0
}
