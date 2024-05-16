#!/usr/bin/env bash

koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2024-05-16.
    # """
    koopa_python_script 'prune-apps.py'
    return 0
}
