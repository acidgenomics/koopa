#!/usr/bin/env bash

koopa_unlink_in_man1() {
    # """
    # Unlink documentation in koopa 'MANPATH' man1 directory.
    # @note Updated 2022-08-03.
    #
    # @usage
    # > koopa_unlink_in_man1 TARGET_NAME...
    #
    # @examples
    # > koopa_link_in_man1 'cp.1' 'mv.1'
    # """
    koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(koopa_man_prefix)/man1" \
        "$@"
}
