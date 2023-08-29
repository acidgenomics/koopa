#!/usr/bin/env bash

main() {
    # """
    # Install hugo.
    # @note Updated 2023-08-29.
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
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['ldflags']='-s -w'
    dict['tags']='extended'
    dict['url']="https://github.com/gohugoio/hugo/archive/\
v${dict['version']}.tar.gz"
    koopa_install_go_package \
        --ldflags="${dict['ldflags']}" \
        --name="${dict['name']}" \
        --prefix="${dict['prefix']}" \
        --tags="${dict['tags']}" \
        --url="${dict['url']}" \
        --version="${dict['version']}"
    return 0
}
