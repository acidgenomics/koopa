#!/usr/bin/env bash

koopa_rhel_enable_epel() {
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL) for Red Hat
    # Enterprise Linux (RHEL).
    # @note Updated 2022-02-17.
    # """
    koopa_assert_has_no_args "$#"
    if koopa_fedora_dnf repolist \
        | koopa_str_detect_regex - --pattern='^epel'
    then
        koopa_alert_success 'EPEL is already enabled.'
        return 0
    fi
    koopa_fedora_dnf_install "https://dl.fedoraproject.org/pub/\
epel/epel-release-latest-8.noarch.rpm"
    return 0
}
