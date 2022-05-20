#!/usr/bin/env bash

koopa_link_in_sbin() {
    # """
    # Link a program in koopa 'sbin/ directory.
    # @note Updated 2022-04-06.
    # 
    # @usage
    # > koopa_link_in_sbin \
    # >     SOURCE_FILE_1 TARGET_NAME_1 \
    # >     SOURCE_FILE_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_sbin \
    # >     '/Library/TeX/texbin/tlmgr' 'tlmgr'
    # """
    __koopa_link_in_dir --prefix="$(koopa_sbin_prefix)" "$@"
}
