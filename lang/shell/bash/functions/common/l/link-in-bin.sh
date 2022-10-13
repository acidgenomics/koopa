#!/usr/bin/env bash

koopa_link_in_bin() {
    # """
    # Link a program in koopa 'bin/' directory.
    # @note Updated 2022-08-02.
    #
    # Also updates corresponding 'man1' files automatically, when applicable.
    #
    # @usage
    # > koopa_link_in_bin \
    # >     --source=SOURCE_FILE \
    # >     --target=TARGET_NAME
    #
    # @examples
    # > koopa_link_in_bin \
    # >     --name='emacs' \
    # >     --source='/usr/local/bin/emacs'
    # """
    __koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}
