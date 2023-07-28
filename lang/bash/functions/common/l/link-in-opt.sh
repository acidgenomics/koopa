#!/usr/bin/env bash

koopa_link_in_opt() {
    # """
    # Link an application in koopa 'opt/' directory.
    # @note Updated 2023-07-28.
    #
    # @usage
    # > koopa_link_in_opt \
    # >     --source=SOURCE_DIR \
    # >     --name=TARGET_NAME \
    #
    # @examples
    # > koopa_link_in_opt \
    # >     --name='r' \
    # >     --source='/opt/koopa/app/r/4.3.1'
    # """
    koopa_link_in_dir --prefix="$(koopa_opt_prefix)" "$@"
}
