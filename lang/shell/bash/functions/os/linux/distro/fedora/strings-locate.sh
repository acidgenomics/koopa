#!/usr/bin/env bash

koopa::fedora_locate_rpm() { # {{{1
    # """
    # Locate Fedora 'dnf'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/usr/bin/dnf'
}

koopa::fedora_locate_rpm() { # {{{1
    # """
    # Locate Fedora 'rpm'.
    # @note Updated 2021-11-02.
    # """
    koopa::locate_app '/usr/bin/rpm'
}
