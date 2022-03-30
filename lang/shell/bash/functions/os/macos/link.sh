#!/usr/bin/env bash

koopa_macos_link_bbedit() { # {{{1
    # """
    # Link BBEdit.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        "$(koopa_koopa_prefix)/bin/bbedit"
    return 0
}

koopa_macos_link_google_cloud_sdk() { # {{{1
    # """
    # Link Google Cloud SDK.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        "$(koopa_homebrew_prefix)/Caskroom/google-cloud-sdk/latest/\
google-cloud-sdk/bin/gcloud" \
        "$(koopa_koopa_prefix)/bin/gcloud"
    return 0
}

koopa_macos_link_visual_studio_code() { # {{{1
    # """
    # Link Visual Studio Code.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        "$(koopa_koopa_prefix)/bin/code"
    return 0
}
