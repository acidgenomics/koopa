#!/usr/bin/env bash

koopa_is_xcode_clt_installed() {
    # """
    # Is Xcode CLT (command line tools) installed?
    # @note Updated 2021-10-26.
    # """
    koopa_assert_has_no_args "$#"
    koopa_is_macos || return 1
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]] || return 1
    return 0
}
