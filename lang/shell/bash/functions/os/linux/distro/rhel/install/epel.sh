#!/usr/bin/env bash

koopa::rhel_enable_epel() { # {{{1
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL) for Red Hat
    # Enterprise Linux (RHEL).
    # @note Updated 2021-06-16.
    # """
    local grep rpm
    koopa::assert_has_no_args "$#"
    grep="$(koopa::locate_grep)"
    if koopa::fedora_dnf repolist | "$grep" -q 'epel/'
    then
        koopa::alert_success 'EPEL is already enabled.'
        return 0
    fi
    rpm='https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'
    koopa::fedora_dnf_install "$rpm"
    return 0
}

