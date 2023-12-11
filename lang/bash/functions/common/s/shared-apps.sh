#!/usr/bin/env bash

koopa_shared_apps() {
    # """
    # Enabled shared apps to be installed by default.
    # @note Updated 2023-12-11.
    #
    # @examples
    # koopa_shared_apps
    # """
    koopa_python_script 'shared-apps.py' "$@"
    return 0
}
