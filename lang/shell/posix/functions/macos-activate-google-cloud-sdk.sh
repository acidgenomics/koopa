#!/bin/sh

koopa_macos_activate_google_cloud_sdk() {
    # """
    # Activate macOS Google Cloud SDK Homebrew cask.
    # @note Updated 2022-05-23.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#mac
    # """
    CLOUDSDK_PYTHON="$(koopa_homebrew_opt_prefix)/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON
    return 0
}
