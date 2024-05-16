#!/usr/bin/env bash

koopa_prune_app_binaries() {
    # """
    # Prune app binary tarballs on AWS S3.
    # @note Updated 2024-05-16.
    # """
    koopa_python_script 'prune-app-binaries.py'
    return 0
}
