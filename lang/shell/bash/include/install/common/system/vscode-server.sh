#!/usr/bin/env bash

main() {
    # """
    # Install Visual Studio Code Server.
    # @note Updated 2022-10-07.
    #
    # Currently installs at '/usr/local/bin/code-server'.
    # Hard-coded by 'INSTALL_LOCATION' variable in 'setup.sh' script currently.
    #
    # Can improve this to install directly into koopa in a future update.
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
