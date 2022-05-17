#!/usr/bin/env bash

koopa_unlink_in_opt() {
    # """
    # Unlink a program symlinked in koopa 'opt/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_opt NAME...
    #
    # @examples
    # > koopa_unlink_in_opt 'python' 'r'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}
