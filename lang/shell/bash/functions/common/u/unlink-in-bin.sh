#!/usr/bin/env bash

koopa_unlink_in_bin() {
    # """
    # Unlink a program symlinked in koopa 'bin/ directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_bin NAME...
    #
    # @examples
    # > koopa_unlink_in_bin 'R' 'Rscript'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}
