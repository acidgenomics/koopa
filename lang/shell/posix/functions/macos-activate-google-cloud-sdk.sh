#!/bin/sh

koopa_macos_activate_google_cloud_sdk() {
    # """
    # Activate macOS Google Cloud SDK Homebrew cask.
    # @note Updated 2022-06-13.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#mac
    # """
    CLOUDSDK_PYTHON="$(koopa_opt_prefix)/python/bin/python3"
    export CLOUDSDK_PYTHON
    return 0
}
