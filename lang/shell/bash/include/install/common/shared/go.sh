#!/usr/bin/env bash

# FIXME This isn't working for Apple Silicon.

main() {
    # """
    # Install Go.
    # @note Updated 2022-08-02.
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/go.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. "amd64".
        ['name']='go'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_macos
    then
        dict['os_id']='darwin'
    else
        dict['os_id']='linux'
    fi
    dict['file']="${dict['name']}${dict['version']}.${dict['os_id']}-\
${dict['arch']}.tar.gz"
    dict['url']="https://dl.google.com/${dict['name']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cp --target-directory="${dict['prefix']}" "${dict['name']}/"*
    app['go']="${dict['prefix']}/bin/go"
    koopa_assert_is_installed "${app['go']}"
    return 0
}
