#!/usr/bin/env bash

koopa_link_in_bin() {
    # """
    # Link a program in koopa 'bin/' directory.
    # @note Updated 2022-04-06.
    #
    # @usage
    # > koopa_link_in_bin \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_bin \
    # >     '/usr/local/bin/emacs' 'emacs' \
    # >     '/usr/local/bin/vim' 'vim'
    # """
    __koopa_link_in_dir --prefix="$(koopa_bin_prefix)" "$@"
}
