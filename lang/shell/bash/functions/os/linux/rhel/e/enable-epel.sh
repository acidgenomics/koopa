#!/usr/bin/env bash

# FIXME Need to get epel version dynamically here.

koopa_rhel_enable_epel() {
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL).
    # @note Updated 2023-01-06.
    # """
    local rhel_version
    koopa_assert_has_no_args "$#"
    if koopa_fedora_dnf repolist \
        | koopa_str_detect_regex - --pattern='^epel'
    then
        koopa_alert_success 'EPEL is already enabled.'
        return 0
    fi
    rhel_version='9' # FIXME
    koopa_fedora_dnf_install "https://dl.fedoraproject.org/pub/\
epel/epel-release-latest-${rhel_version}.noarch.rpm"
    return 0
}