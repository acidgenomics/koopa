#!/usr/bin/env bash

koopa::rhel_enable_epel() { # {{{1
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL) for Red Hat
    # Enterprise Linux (RHEL).
    # @note Updated 2021-10-25.
    # """
    local rpm
    koopa::assert_has_no_args "$#"
    if koopa::fedora_dnf repolist \
        | koopa::str_match_fixed 'epel/'
    then
        koopa::alert_success 'EPEL is already enabled.'
        return 0
    fi
    rpm='https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'
    koopa::fedora_dnf_install "$rpm"
    return 0
}
