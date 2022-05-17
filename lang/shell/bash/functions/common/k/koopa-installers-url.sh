#!/usr/bin/env bash

koopa_koopa_installers_url() {
    # """
    # Koopa installers URL.
    # @note Updated 2022-01-06.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_koopa_url)/installers"
}
