#!/usr/bin/env bash

main() {
    # """
    # Install Aspera Connect.
    # @note Updated 2023-06-01.
    #
    # Script install target is currently hard-coded in IBM's install script.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local -A dict
    _koopa_assert_is_not_arm64
    dict['arch']="$(_koopa_arch)"
    dict['aspera_user_prefix']="${HOME}/.aspera"
    dict['platform']='linux'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['script_target']="${dict['aspera_user_prefix']}/connect"
    dict['url']="https://d3gcli72yxqn2z.cloudfront.net/downloads/connect/\
latest/bin/ibm-aspera-connect_${dict['version']}_${dict['platform']}_\
${dict['arch']}.tar.gz"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    "./ibm-aspera-connect_${dict['version']}_${dict['platform']}\
_${dict['arch']}.sh"
    _koopa_assert_is_dir "${dict['script_target']}"
    if [[ "${dict['prefix']}" != "${dict['script_target']}" ]]
    then
        _koopa_cp "${dict['script_target']}" "${dict['prefix']}"
        _koopa_rm "${dict['script_target']}" "${dict['aspera_user_prefix']}"
    fi
    _koopa_assert_is_installed "${dict['prefix']}/bin/ascp"
    return 0
}
