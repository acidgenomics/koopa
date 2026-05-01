#!/usr/bin/env bash

_koopa_unlink_in_opt() {
    # """
    # Unlink a program symlinked in koopa 'opt/' directory.
    # @note Updated 2022-08-10.
    #
    # @usage _koopa_unlink_in_opt NAME...
    #
    # @examples
    # > _koopa_unlink_in_opt 'python3.13' 'r'
    # """
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_opt_prefix)" \
        "$@"
}
