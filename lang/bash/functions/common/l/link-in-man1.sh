#!/usr/bin/env bash

# FIXME This should error when we fail to link.
# e.g. 'wget2.1', due to bsd sed / missing doxygen.

koopa_link_in_man1() {
    # """
    # Link documentation into koopa 'MANPATH' man1 directory.
    # @note Updated 2022-08-02.
    #
    # @usage
    # > koopa_link_in_man1 \
    # >     --source=SOURCE_FILE \
    # >     --target=TARGET_NAME
    #
    # @examples
    # > koopa_link_in_man1 \
    # >     --name='cp.1' \
    # >     --source='/opt/koopa/app/coreutils/9.1/share/man/man1/cp.1'
    # """
    koopa_link_in_dir --prefix="$(koopa_man_prefix)/man1" "$@"
}
