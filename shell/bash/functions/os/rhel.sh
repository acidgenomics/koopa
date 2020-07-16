#!/usr/bin/env bash

koopa::rhel_enable_epel() { # {{{1
    koopa::assert_has_no_args "$#"
    if sudo dnf repolist | grep -q 'epel/'
    then
        koopa::success 'EPEL is already enabled.'
        return 0
    fi
    sudo dnf install -y \
        'https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm'
    return 0
}

koopa::rhel_install_base() { # {{{1
    # """
    # Install Red Hat Enterprise Linux (RHEL) base system.
    # @note Updated 2020-07-14.
    #
    # Note that RHEL 8+ now uses dnf instead of yum.
    # """
    local dev extra name_fancy pkgs
    koopa::assert_is_installed dnf sudo
    dev=1
    extra=1
    koopa::is_docker && extra=0
    # Install Fedora base first.
    koopa::fedora_install_base "$@"
    name_fancy='Red Hat Enterprise Linux (RHEL) base system'
    koopa::install_start "$name_fancy"

    # Default {{{2
    # --------------------------------------------------------------------------

    koopa::h2 'Installing default packages.'
    # 'dnf-plugins-core' installs 'config-manager'.
    sudo dnf -y install dnf-plugins-core util-linux-user
    sudo dnf config-manager --set-enabled PowerTools
    koopa::rhel_enable_epel

    # Developer {{{2
    # --------------------------------------------------------------------------

    if [[ "$dev" -eq 1 ]]
    then
        koopa::h2 "Installing developer libraries."
        pkgs=('libgit2' 'libssh2')
        sudo dnf -y install "${pkgs[@]}"
    fi

    # Extra {{{2
    # --------------------------------------------------------------------------

    if [[ "$extra" -eq 1 ]]
    then
        koopa::h2 "Installing extra recommended packages."
        sudo dnf -y install python3
    fi

    koopa::install_success "$name_fancy"
    return 0
}
