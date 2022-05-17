#!/usr/bin/env bash

koopa_cli_configure() {
    # """
    # Parse user input to 'koopa configure'.
    # @note Updated 2022-02-15.
    #
    # @examples
    # > koopa_cli_configure 'python'
    # """
    koopa_cli_nested_runner 'configure' "$@"
}
