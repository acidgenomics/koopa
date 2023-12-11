#!/usr/bin/env bash

koopa_prune_app_binaries() {
    # """
    # Prune app binary tarballs on AWS S3.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_no_args "$#"
    # FIXME Add support for this.
    koopa_python_script 'prune-app-binaries.py'
    return 0
}
