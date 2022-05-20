#!/usr/bin/env bash

koopa_cli_update() {
    # """
    # Parse user input to 'koopa update'.
    # @note Updated 2022-03-09.
    #
    # @examples
    # > koopa_cli_update 'dotfiles'
    # """
    [[ "$#" -eq 0 ]] && set -- 'koopa'
    koopa_cli_nested_runner 'update' "$@"
}
