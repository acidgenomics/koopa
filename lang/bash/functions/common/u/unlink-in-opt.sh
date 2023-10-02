#!/usr/bin/env bash

koopa_unlink_in_opt() {
    # """
    # Unlink a program symlinked in koopa 'opt/' directory.
    # @note Updated 2022-08-10.
    #
    # @usage koopa_unlink_in_opt NAME...
    #
    # @examples
    # > koopa_unlink_in_opt 'python3.12' 'r'
    # """
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_opt_prefix)" \
        "$@"
}
