#!/bin/sh

_koopa_activate_google_cloud_sdk() {
    # """
    # Activate Google Cloud SDK.
    # @note Updated 2023-07-28.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install
    # """
    __kvar_bin_prefix="$(_koopa_bin_prefix)"
    if [ ! -x "${__kvar_bin_prefix}/gcloud" ]
    then
        unset -v __kvar_bin_prefix
        return 0
    fi
    CLOUDSDK_PYTHON="${__kvar_bin_prefix}/python3.11"
    export CLOUDSDK_PYTHON
    unset -v __kvar_bin_prefix
    return 0
}
