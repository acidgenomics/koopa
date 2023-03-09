#!/bin/sh

_koopa_activate_google_cloud_sdk() {
    # """
    # Activate Google Cloud SDK.
    # @note Updated 2023-01-03.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # """
    local python
    python="$(_koopa_bin_prefix)/python3.10"
    [ -x "$python" ] || return 0
    CLOUDSDK_PYTHON="$python"
    export CLOUDSDK_PYTHON
    return 0
}
