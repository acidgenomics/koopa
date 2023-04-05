#!/usr/bin/env bash

koopa_ssh_key_info() {
    # """
    # Get SSH key information.
    # @note Updated 2022-05-18.
    #
    # @seealso
    # - https://blog.g3rt.nl/upgrade-your-ssh-keys.html
    # """
    local app dict keyfile
    declare -A app=(
        ['ssh_keygen']="$(koopa_locate_ssh_keygen)"
        ['uniq']="$(koopa_locate_uniq)"
    )
    [[ -x "${app['ssh_keygen']}" ]] || exit 1
    [[ -x "${app['uniq']}" ]] || exit 1
    declare -A dict=(
        ['prefix']="${HOME:?}/.ssh"
        ['stem']='id_'
    )
    for keyfile in "${dict['prefix']}/${dict['stem']}"*
    do
        "${app['ssh_keygen']}" -l -f "$keyfile"
    done | "${app['uniq']}"
    return 0
}
