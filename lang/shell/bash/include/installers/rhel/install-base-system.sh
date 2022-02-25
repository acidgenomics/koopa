#!/usr/bin/env bash

rhel_install_base_system() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2021-11-30.
    #
    # 'dnf-plugins-core' installs 'config-manager'.
    # """
    local dict
    koopa_assert_is_admin
    declare -A dict
    koopa_fedora_install_base_system "$@"
    # Early return for legacy RHEL 7 configs (e.g. Amazon Linux 2).
    if koopa_is_amzn || koopa_is_rhel_7_like
    then
        return 0
    fi
    koopa_fedora_dnf_install 'dnf-plugins-core' 'util-linux-user'
    koopa_rhel_enable_epel
    if koopa_is_centos || koopa_is_rocky
    then
        dict[powertools]='powertools'
    else
        dict[powertools]='PowerTools'
    fi
    if ! koopa_is_rhel_ubi
    then
        koopa_fedora_dnf config-manager --set-enabled "${dict[powertools]}"
    fi
    return 0
}
