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

