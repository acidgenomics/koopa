#!/usr/bin/env bash

_koopa_prune_app_binaries() {
    # """
    # Prune app binary tarballs on AWS S3.
    # @note Updated 2024-06-21.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_assert_can_push_binary
    _koopa_python_script 'prune-app-binaries.py'
    return 0
}
