#!/usr/bin/env bash

_koopa_link_in_opt() {
    # """
    # Link an application in koopa 'opt/' directory.
    # @note Updated 2023-07-28.
    #
    # @usage
    # > _koopa_link_in_opt \
    # >     --source=SOURCE_DIR \
    # >     --name=TARGET_NAME \
    #
    # @examples
    # > _koopa_link_in_opt \
    # >     --name='r' \
    # >     --source='/opt/koopa/app/r/4.3.1'
    # """
    _koopa_link_in_dir --prefix="$(_koopa_opt_prefix)" "$@"
}
