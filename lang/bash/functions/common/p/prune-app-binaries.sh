#!/usr/bin/env bash

# FIXME Rework this in Python.

koopa_prune_app_binaries() {
    # """
    # Prune app binary tarballs on AWS S3.
    # @note Updated 2023-10-03.
    # """
    koopa_r_koopa 'cliPruneAppBinaries' "$@"
    return 0
}
