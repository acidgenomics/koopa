#!/bin/sh

koopa_macos_activate_google_cloud_sdk() {
    # """
    # Activate macOS Google Cloud SDK Homebrew cask.
    # @note Updated 2022-04-04.
    #
    # Alternate (slower) approach that enables autocompletion.
    # > local prefix shell
    # > prefix="$(koopa_homebrew_cask_prefix)/google-cloud-sdk/\
    # > latest/google-cloud-sdk"
    # > [ -d "$prefix" ] || return 0
    # > shell="$(koopa_shell_name)"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/path.${shell}.inc" ] && \
    # >     . "${prefix}/path.${shell}.inc"
    # > # shellcheck source=/dev/null
    # > [ -f "${prefix}/completion.${shell}.inc" ] && \
    # >     . "${prefix}/completion.${shell}.inc"
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#mac
    # """
    CLOUDSDK_PYTHON="$(koopa_homebrew_opt_prefix)/python@3.9/bin/python3.9"
    export CLOUDSDK_PYTHON
    return 0
}
