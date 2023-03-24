#!/usr/bin/env bash

main() {
    # """
    # Install Quarto.
    # @note Updated 2023-03-24.
    #
    # @seealso
    # - https://quarto.org/docs/download/
    # - https://github.com/quarto-dev/quarto-cli/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. "amd64".
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    if koopa_is_linux
    then
        dict['slug']="linux-${dict['arch']}"
    elif koopa_is_macos
    then
        dict['slug']='macos'
    fi
    dict['file']="${dict['name']}-${dict['version']}-${dict['slug']}.tar.gz"
    dict['url']="https://github.com/quarto-dev/quarto-cli/releases/download/\
v${dict['version']}/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    if koopa_is_macos
    then
        koopa_cp \
            --target-directory="${dict['prefix']}" \
            'bin' 'share'
    else
        koopa_cp \
            --target-directory="${dict['prefix']}" \
            "${dict['name']}-${dict['version']}/"*
    fi
    return 0
}
