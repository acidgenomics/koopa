#!/usr/bin/env bash

koopa_unlink_in_bin() {
    # """
    # Unlink a program symlinked in koopa 'bin/ directory.
    # @note Updated 2022-08-03.
    #
    # @usage koopa_unlink_in_bin NAME...
    #
    # @examples
    # > koopa_unlink_in_bin 'R' 'Rscript'
    # """
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_bin_prefix)" \
        "$@"
}
