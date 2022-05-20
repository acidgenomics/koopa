#!/usr/bin/env bash

# FIXME Need to locate gpgconf.

koopa_gpg_restart() {
    koopa_assert_has_no_args "$#"
    koopa_assert_is_installed 'gpgconf'
    gpgconf --kill gpg-agent
    return 0
}
