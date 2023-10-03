#!/usr/bin/env bash

# FIXME Rework this in Python.

koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2023-10-03.
    # """
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}
