#!/usr/bin/env bash

# NOTE Currently seeing this in 'hugo version' return on macOS:
# BuildDate=unknown

main() {
    # """
    # Install hugo.
    # @note Updated 2023-03-02.
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
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'go'
    local -A app
    app['go']="$(koopa_locate_go)"
    [[ -x "${app['go']}" ]] || exit 1
    local -A dict=(
        ['gocache']="$(koopa_init_dir 'gocache')"
        ['gopath']="$(koopa_init_dir 'go')"
        ['name']='hugo'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['file']="v${dict['version']}.tar.gz"
    dict['url']="https://github.com/gohugoio/${dict['name']}/\
archive/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['name']}-${dict['version']}"
    koopa_print_env
    "${app['go']}" build \
        -ldflags '-s -w' \
        -tags 'extended' \
        -o "${dict['prefix']}/bin/${dict['name']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
