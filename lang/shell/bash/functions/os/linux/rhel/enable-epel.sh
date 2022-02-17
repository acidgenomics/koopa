#!/usr/bin/env bash

koopa::rhel_enable_epel() { # {{{1
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL) for Red Hat
    # Enterprise Linux (RHEL).
    # @note Updated 2022-02-17.
    # """
    koopa::assert_has_no_args "$#"
    if koopa::fedora_dnf repolist \
        | koopa::str_detect_regex - --pattern='^epel'
    then
        koopa::alert_success 'EPEL is already enabled.'
        return 0
    fi
    koopa::fedora_dnf_install "https://dl.fedoraproject.org/pub/\
epel/epel-release-latest-8.noarch.rpm"
    return 0
}
