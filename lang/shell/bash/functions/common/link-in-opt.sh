#!/usr/bin/env bash

koopa_link_in_opt() {
    # """
    # Link an application in koopa 'opt/' directory.
    # @note Updated 2022-04-08.
    #
    # @usage
    # > koopa_link_in_opt \
    # >     SOURCE_DIR_1 TARGET_NAME_1 \
    # >     SOURCE_DIR_2 TARGET_NAME_2 \
    # >     ...
    #
    # @examples
    # > koopa_link_in_opt \
    # >     '/opt/koopa/app/python/3.10.0' 'python' \
    # >     '/opt/koopa/app/r/3.4.0' 'r'
    # """
    __koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}
