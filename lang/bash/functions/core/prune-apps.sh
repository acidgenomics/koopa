#!/usr/bin/env bash

# TODO Ensure we delete any broken symlinks in 'bin' and 'man' directories.

_koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2024-05-16.
    # """
    _koopa_python_script 'prune-apps.py'
    return 0
}
