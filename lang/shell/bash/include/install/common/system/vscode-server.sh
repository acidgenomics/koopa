#!/usr/bin/env bash

main() {
    # """
    # Install Visual Studio Code Server.
    # @note Updated 2022-10-07.
    #
    # @seealso
    # - https://code.visualstudio.com/docs/remote/vscode-server
    # """
    local dict
    declare -A dict
    dict['file']='setup.sh'
    dict['url']="https://aka.ms/install-vscode-server/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod +x "${dict['file']}"
    ./"${dict['file']}"
    return 0
}
