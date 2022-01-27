#!/usr/bin/env bash

koopa:::fedora_uninstall_oracle_instant_client() { # {{{1
    # """
    # Uninstall Oracle Instant Client.
    # @note Updated 2022-01-27.
    # """
    koopa::fedora_dnf_remove 'oracle-instantclient*'
    koopa::rm --sudo '/etc/ld.so.conf.d/oracle-instantclient.conf'
    return 0
}
