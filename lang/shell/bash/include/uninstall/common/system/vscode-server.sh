#!/usr/bin/env bash

main() {
    # """
    # Uninstall Visual Studio Code Server
    # @note Updated 2022-10-13.
    # """
    koopa_rm --sudo '/usr/local/bin/code-server'
    return 0
}
