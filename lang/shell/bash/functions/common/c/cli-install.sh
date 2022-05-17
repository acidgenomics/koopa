#!/usr/bin/env bash

koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa_cli_install 'python'
    # """
    koopa_cli_nested_runner 'install' "$@"
}
