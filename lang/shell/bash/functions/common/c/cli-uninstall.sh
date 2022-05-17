#!/usr/bin/env bash

koopa_cli_uninstall() {
    # """
    # Parse user input to 'koopa uninstall'.
    # @note Updated 2022-02-15.
    #
    # @seealso
    # > koopa_cli_uninstall 'python'
    # """
    koopa_cli_nested_runner 'uninstall' "$@"
}
