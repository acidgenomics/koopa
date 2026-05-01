#!/usr/bin/env bash

_koopa_unlink_in_man1() {
    # """
    # Unlink documentation in koopa 'MANPATH' man1 directory.
    # @note Updated 2022-08-03.
    #
    # @usage
    # > _koopa_unlink_in_man1 TARGET_NAME...
    #
    # @examples
    # > _koopa_link_in_man1 'cp.1' 'mv.1'
    # """
    _koopa_unlink_in_dir \
        --allow-missing \
        --prefix="$(_koopa_man_prefix)/man1" \
        "$@"
}
