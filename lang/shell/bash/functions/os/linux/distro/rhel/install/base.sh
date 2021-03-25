#!/usr/bin/env bash

koopa::rhel_install_base() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2021-03-25.
    #
    # 'dnf-plugins-core' installs 'config-manager'.
    # """
    local name_fancy powertools
    koopa::fedora_install_base "$@"
    # Early return for legacy RHEL 7 configs (e.g. Amazon Linux 2).
    koopa::is_rhel_7_like && return 0
    koopa::assert_is_installed dnf sudo
    name_fancy='Red Hat Enterprise Linux (RHEL) base system'
    koopa::install_start "$name_fancy"
    sudo dnf -y install 'dnf-plugins-core' 'util-linux-user'
    koopa::rhel_enable_epel
    if koopa::is_centos
    then
        powertools='powertools'
    else
        powertools='PowerTools'
    fi
    if ! koopa::is_rhel_ubi
    then
        sudo dnf config-manager --set-enabled "$powertools"
    fi
    koopa::install_success "$name_fancy"
    return 0
}
