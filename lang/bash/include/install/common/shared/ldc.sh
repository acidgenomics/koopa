#!/usr/bin/env bash

main() {
    # """
    # Install a D language compiler.
    # @note Updated 2023-08-18.
    #
    # Supported: dmd, gdc, ldc.
    #
    # @seealso
    # - https://dlang.org/download.html
    # - https://wiki.dlang.org/Building_LDC_from_source
    # - https://github.com/conda-forge/ldc-feedstock
    # - https://formulae.brew.sh/formula/ldc
    # """
    local -A dict
    koopa_activate_app 'gnupg' 'libarchive' 'xz'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']='https://dlang.org/install.sh'
    dict['script']="$(koopa_basename "${dict['url']}")"
    koopa_download "${dict['url']}"
    koopa_chmod +x "${dict['script']}"
    "./${dict['script']}" \
        --path "${PWD:?}" \
        "${dict['name']}-${dict['version']}"
    koopa_cp "${dict['name']}-${dict['version']}" "${dict['prefix']}"
    return 0
}
