#!/usr/bin/env bash

# FIXME Work on a similar approach for bbedit tools.

koopa_macos_configure_visual_studio_code() { # {{{1
    # """
    # Configure Visual Studio Code.
    # @note Updated 2022-03-30.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [source]="/Applications/Visual Studio Code.app/Contents/Resources/app/\
bin/code"
        [target]="$(koopa_koopa_prefix)/bin/code"
    )
    koopa_sys_ln "${dict[source]}" "${dict[target]}"
    return 0
}
