#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Oracle Instant Client.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_fedora_dnf_remove 'oracle-instantclient*'
    koopa_rm --sudo '/etc/ld.so.conf.d/oracle-instantclient.conf'
    return 0
}
