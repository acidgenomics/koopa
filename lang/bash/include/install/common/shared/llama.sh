#!/usr/bin/env bash

main() {
    # """
    # Install llama.
    # @note Updated 2023-08-29.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/llama.rb
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/antonmedv/llama/archive/refs/tags/\
v${dict['version']}.tar.gz"
    dict['ldflags']='-s -w'
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='llama' \
        -D "--ldflags=${dict['ldflags']}" \
        -D "--url=${dict['url']}"
    return 0
}
