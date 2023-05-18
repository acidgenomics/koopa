#!/usr/bin/env bash

koopa_macos_is_xcode_clt_installed() {
    # """
    # Is Xcode CLT (command line tools) installed?
    # @note Updated 2022-10-11.
    # """
    koopa_assert_has_no_args "$#"
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]]
}
