#!/usr/bin/env bash

_koopa_unlink_in_bin() {
    # """
    # Unlink a program symlinked in koopa 'bin/ directory.
    # @note Updated 2022-08-03.
    #
    # @usage _koopa_unlink_in_bin NAME...
    #
    # @examples
    # > _koopa_unlink_in_bin 'R' 'Rscript'
    # """
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_bin_prefix)" \
        "$@"
}
