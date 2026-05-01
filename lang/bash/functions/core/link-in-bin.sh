#!/usr/bin/env bash

_koopa_link_in_bin() {
    # """
    # Link a program in koopa 'bin/' directory.
    # @note Updated 2022-08-02.
    #
    # Also updates corresponding 'man1' files automatically, when applicable.
    #
    # @usage
    # > _koopa_link_in_bin \
    # >     --source=SOURCE_FILE \
    # >     --target=TARGET_NAME
    #
    # @examples
    # > _koopa_link_in_bin \
    # >     --name='emacs' \
    # >     --source='/usr/local/bin/emacs'
    # """
    _koopa_link_in_dir --prefix="$(_koopa_bin_prefix)" "$@"
}
