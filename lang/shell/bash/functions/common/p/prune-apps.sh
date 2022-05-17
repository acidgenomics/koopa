#!/usr/bin/env bash

koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2021-08-14.
    # """
    if koopa_is_macos
    then
        koopa_alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}
