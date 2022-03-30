#!/usr/bin/env bash

koopa_macos_configure_bbedit() { # {{{1
    # """
    # Configure BBEdit.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        "$(koopa_koopa_prefix)/bin/bbedit"
    return 0
}

koopa_macos_configure_visual_studio_code() { # {{{1
    # """
    # Configure Visual Studio Code.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        "$(koopa_koopa_prefix)/bin/code"
    return 0
}
