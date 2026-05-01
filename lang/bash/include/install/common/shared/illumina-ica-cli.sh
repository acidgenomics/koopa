#!/usr/bin/env bash

main() {
    # """
    # Install Illumina ICA CLI.
    # @note Updated 2025-12-08.
    #
    # @seealso
    # - https://help.ica.illumina.com/command-line-interface/cli-installation
    # """
    local -A dict
    dict['arch']="$(_koopa_arch2)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if _koopa_is_macos
    then
        dict['os']='darwin'
    else

        dict['os']='linux'
    fi
    dict['url']="https://stratus-documentation-us-east-1-public.s3.\
amazonaws.com/cli/${dict['version']}/ica-${dict['os']}-${dict['arch']}.zip"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_cp --target-directory="${dict['prefix']}/bin" 'icav2'
    return 0
}
