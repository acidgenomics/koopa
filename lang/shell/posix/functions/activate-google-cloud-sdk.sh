#!/bin/sh

koopa_activate_google_cloud_sdk() {
    # """
    # Activate Google Cloud SDK.
    # @note Updated 2022-07-07.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # """
    local python
    if koopa_is_macos
    then
        python="$(koopa_opt_prefix)/python/bin/python3"
    else
        python='/usr/bin/python3'
    fi
    CLOUDSDK_PYTHON="$python"
    export CLOUDSDK_PYTHON
    return 0
}
