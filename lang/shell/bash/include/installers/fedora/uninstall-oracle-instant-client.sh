#!/usr/bin/env bash

fedora_uninstall_oracle_instant_client() { # {{{1
    # """
    # Uninstall Oracle Instant Client.
    # @note Updated 2022-01-27.
    # """
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    koopa_fedora_dnf_remove 'oracle-instantclient*'
    koopa_rm --sudo '/etc/ld.so.conf.d/oracle-instantclient.conf'
    return 0
}
