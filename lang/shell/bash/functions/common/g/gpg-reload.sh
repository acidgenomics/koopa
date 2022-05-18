#!/usr/bin/env bash

# FIXME Need to locate gpg-connect-agent.

koopa_gpg_reload() {
    koopa_assert_has_no_args "$#"
    koopa_assert_is_installed 'gpg-connect-agent'
    gpg-connect-agent reloadagent '/bye'
    return 0
}
