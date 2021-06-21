#!/usr/bin/env bash

koopa::rhel_install_base() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2021-06-16.
    #
    # 'dnf-plugins-core' installs 'config-manager'.
    # """
    local name_fancy powertools
    koopa::fedora_install_base "$@"
    # Early return for legacy RHEL 7 configs (e.g. Amazon Linux 2).
    if koopa::is_amzn || koopa::is_rhel_7_like
    then
        return 0
    fi
    koopa::assert_is_installed 'dnf' 'sudo'
    name_fancy='Red Hat Enterprise Linux (RHEL) base system'
    koopa::install_start "$name_fancy"
    koopa::fedora_dnf_install 'dnf-plugins-core' 'util-linux-user'
    koopa::rhel_enable_epel
    if koopa::is_centos || koopa::is_rocky
    then
        powertools='powertools'
    else
        powertools='PowerTools'
    fi
    if ! koopa::is_rhel_ubi
    then
        koopa::fedora_dnf config-manager --set-enabled "$powertools"
    fi
    koopa::install_success "$name_fancy"
    return 0
}
