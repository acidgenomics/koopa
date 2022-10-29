#!/bin/sh

koopa_activate_google_cloud_sdk() {
    # """
    # Activate Google Cloud SDK.
    # @note Updated 2022-10-29.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # """
    local python
    python="$(koopa_bin_prefix)/python3.10"
    [ -x "$python" ] || return 0
    CLOUDSDK_PYTHON="$python"
    export CLOUDSDK_PYTHON
    return 0
}
