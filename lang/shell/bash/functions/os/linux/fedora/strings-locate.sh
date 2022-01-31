#!/usr/bin/env bash

koopa::fedora_locate_dnf() { # {{{1
    koopa::locate_app '/usr/bin/dnf'
}

koopa::fedora_locate_rpm() { # {{{1
    koopa::locate_app '/usr/bin/rpm'
}
