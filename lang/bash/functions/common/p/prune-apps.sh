#!/usr/bin/env bash

koopa_prune_apps() {
    # """
    # Prune applications.
    # @note Updated 2023-12-11.
    # """
    koopa_assert_has_no_args "$#"
    # FIXME Add support for this.
    koopa_python_script 'prune-apps.py'
    return 0
}
