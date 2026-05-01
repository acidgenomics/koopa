#!/usr/bin/env bash

# FIXME This should error when we fail to link.
# e.g. 'wget2.1', due to bsd sed / missing doxygen.

_koopa_link_in_man1() {
    # """
    # Link documentation into koopa 'MANPATH' man1 directory.
    # @note Updated 2022-08-02.
    #
    # @usage
    # > _koopa_link_in_man1 \
    # >     --source=SOURCE_FILE \
    # >     --target=TARGET_NAME
    #
    # @examples
    # > _koopa_link_in_man1 \
    # >     --name='cp.1' \
    # >     --source='/opt/koopa/app/coreutils/9.1/share/man/man1/cp.1'
    # """
    _koopa_link_in_dir --prefix="$(_koopa_man_prefix)/man1" "$@"
}
