#!/usr/bin/env bash

main() {
    # """
    # Install Aspera Connect.
    # @note Updated 2022-03-28.
    #
    # Script install target is currently hard-coded in IBM's install script.
    #
    # @seealso
    # - https://www.ibm.com/aspera/connect/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['aspera_user_prefix']="${HOME}/.aspera"
        ['name']='ibm-aspera-connect'
        ['platform']='linux'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    dict['file']="${dict['name']}_${dict['version']}_${dict['platform']}.tar.gz"
    dict['url']="https://d3gcli72yxqn2z.cloudfront.net/connect_latest/\
v${dict['maj_ver']}/bin/${dict['file']}"
    dict['script']="${dict['file']//.tar.gz/.sh}"
    dict['script_target']="${dict['aspera_user_prefix']}/connect"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    "./${dict['script']}" &>/dev/null
    koopa_assert_is_dir "${dict['script_target']}"
    if [[ "${dict['prefix']}" != "${dict['script_target']}" ]]
    then
        koopa_cp "${dict['script_target']}" "${dict['prefix']}"
        koopa_rm "${dict['script_target']}" "${dict['aspera_user_prefix']}"
    fi
    koopa_chmod 0775 "${dict['prefix']}/var/log"
    koopa_assert_is_installed "${dict['prefix']}/bin/ascp"
    return 0
}
