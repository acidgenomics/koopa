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
    koopa_assert_is_not_arm64
    dict['arch']="$(koopa_arch)"
    dict['aspera_user_prefix']="${HOME}/.aspera"
    dict['platform']='linux'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['script_target']="${dict['aspera_user_prefix']}/connect"
    dict['url']="https://d3gcli72yxqn2z.cloudfront.net/downloads/connect/\
latest/bin/ibm-aspera-connect_${dict['version']}_${dict['platform']}_\
${dict['arch']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    "./ibm-aspera-connect_${dict['version']}_${dict['platform']}\
_${dict['arch']}.sh"
    koopa_assert_is_dir "${dict['script_target']}"
    if [[ "${dict['prefix']}" != "${dict['script_target']}" ]]
    then
        koopa_cp "${dict['script_target']}" "${dict['prefix']}"
        koopa_rm "${dict['script_target']}" "${dict['aspera_user_prefix']}"
    fi
    koopa_assert_is_installed "${dict['prefix']}/bin/ascp"
    return 0
}
