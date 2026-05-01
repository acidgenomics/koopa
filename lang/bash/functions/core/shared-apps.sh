#!/usr/bin/env bash

_koopa_shared_apps() {
    # """
    # Enabled shared apps to be installed by default.
    # @note Updated 2023-12-11.
    #
    # @examples
    # _koopa_shared_apps
    # """
    "${KOOPA_PREFIX:?}/bin/koopa" internal shared-apps "$@"
    return 0
}
