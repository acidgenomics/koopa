#!/usr/bin/env bash

koopa_prune_app_binaries() {
    # """
    # Prune app binary tarballs on AWS S3.
    # @note Updated 2023-01-31.
    # """
    koopa_r_koopa 'cliPruneAppBinaries' "$@"
    return 0
}
