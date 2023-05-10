#!/usr/bin/env bash

# FIXME This step is erroring out for 'r-base' and 'r-base-dev'.

koopa_debian_apt_install() {
    # """
    # Install Debian apt package.
    # @note Updated 2020-06-30.
    # """
    koopa_assert_has_args "$#"
    koopa_debian_apt_get install "$@"
}
