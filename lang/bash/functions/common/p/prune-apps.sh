#!/usr/bin/env bash

koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2023-01-31.
    # """
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}