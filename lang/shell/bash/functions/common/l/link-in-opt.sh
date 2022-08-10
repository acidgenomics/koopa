#!/usr/bin/env bash

koopa_link_in_opt() {
    # """
    # Link an application in koopa 'opt/' directory.
    # @note Updated 2022-08-02.
    #
    # @usage
    # > koopa_link_in_opt \
    # >     --source=SOURCE_DIR \
    # >     --name=TARGET_NAME \
    #
    # @examples
    # > koopa_link_in_opt \
    # >     --name='python' \
    # >     --source='/opt/koopa/app/python/3.10.5'
    # """
    __koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}
