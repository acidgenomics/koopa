#!/usr/bin/env bash

koopa_ssh_key_info() {
    # """
    # Get SSH key information.
    # @note Updated 2023-04-05.
    #
    # @seealso
    # - https://blog.g3rt.nl/upgrade-your-ssh-keys.html
    # """
    local -A app dict
    local keyfile
    app['ssh_keygen']="$(koopa_locate_ssh_keygen --allow-system)"
    app['uniq']="$(koopa_locate_uniq)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="${HOME:?}/.ssh"
    dict['stem']='id_'
    for keyfile in "${dict['prefix']}/${dict['stem']}"*
    do
        "${app['ssh_keygen']}" -l -f "$keyfile"
    done | "${app['uniq']}"
    return 0
}
