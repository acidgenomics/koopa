#!/usr/bin/env bash

main() {
    # """
    # Install hugo.
    # @note Updated 2023-08-28.
    #
    # The '-s' and '-w' ldflags help shrink the size of the binary.
    # Refer to 'go tool link' for details.
    # * -s: disable symbol table.
    # * -w: disable DWARF generation.
    # https://stackoverflow.com/questions/22267189/
    #
    # @seealso
    # - https://gohugo.io/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/hugo.rb
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/gohugoio/hugo/archive/\
v${dict['version']}.tar.gz"
    dict['ldflags']='-s -w'
    dict['tags']='extended'
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='hugo' \
        -D "--ldflags=${dict['ldflags']}" \
        -D "--tags=${dict['tags']}" \
        -D "--url=${dict["url"]}"
    return 0
}
