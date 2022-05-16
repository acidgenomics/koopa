#!/usr/bin/env bash

koopa_unlink_in_sbin() {
    # """
    # Unlink a program symlinked in koopa 'sbin/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage koopa_unlink_in_sbin NAME...
    #
    # @examples
    # > koopa_unlink_in_sbin 'tlmgr'
    # """
    __koopa_unlink_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}
