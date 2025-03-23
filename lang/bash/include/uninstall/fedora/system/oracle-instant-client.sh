#!/usr/bin/env bash

main() {
    # """
    # Uninstall Oracle Instant Client.
    # @note Updated 2022-01-27.
    # """
    koopa_fedora_dnf_remove 'oracle-instantclient*'
    koopa_rm --sudo '/etc/ld.so.conf.d/oracle-instantclient.conf'
    return 0
}
