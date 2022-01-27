#!/usr/bin/env bash

koopa::prune_apps() { # {{{1
    # """
    # Prune applications.
    # @note Updated 2021-08-14.
    # """
    if koopa::is_macos
    then
        koopa::alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa::r_koopa 'cliPruneApps' "$@"
    return 0
}
