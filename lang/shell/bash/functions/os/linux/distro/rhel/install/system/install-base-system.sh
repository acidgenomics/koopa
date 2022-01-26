#!/usr/bin/env bash

koopa::rhel_install_base_system() { # {{{1
    koopa::install_app \
        --name-fancy='Red Hat Enterprise Linux (RHEL) base system' \
        --name='install-base' \
        --system \
        "$@"
}

koopa:::rhel_install_base_system() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2021-11-30.
    #
    # 'dnf-plugins-core' installs 'config-manager'.
    # """
    local dict
    declare -A dict
    koopa::fedora_install_base_system "$@"
    # Early return for legacy RHEL 7 configs (e.g. Amazon Linux 2).
    if koopa::is_amzn || koopa::is_rhel_7_like
    then
        return 0
    fi
    koopa::fedora_dnf_install 'dnf-plugins-core' 'util-linux-user'
    koopa::rhel_enable_epel
    if koopa::is_centos || koopa::is_rocky
    then
        dict[powertools]='powertools'
    else
        dict[powertools]='PowerTools'
    fi
    if ! koopa::is_rhel_ubi
    then
        koopa::fedora_dnf config-manager --set-enabled "${dict[powertools]}"
    fi
    return 0
}
