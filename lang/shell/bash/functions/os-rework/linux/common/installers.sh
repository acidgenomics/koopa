#!/usr/bin/env bash

koopa_linux_install_docker_credential_pass() {
    koopa_install_app \
        --link-in-bin='bin/docker-credential-pass' \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_docker_credential_pass() {
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        --unlink-in-bin='docker-credential-pass' \
        "$@"
}

# julia-binary ------------------------------------------------------------ {{{2

koopa_linux_install_julia_binary() {
    koopa_install_app \
        --installer="julia-binary" \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        --platform='linux' \
        "$@"
}

# lmod -------------------------------------------------------------------- {{{2

koopa_linux_install_lmod() {
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

# FIXME Ensure that this cleans up 'etc/profile.d'
koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}

# System ================================================================== {{{1

# pihole ------------------------------------------------------------------ {{{2

koopa_linux_install_pihole() {
    koopa_update_app \
        --name-fancy='Pi-hole' \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

# FIXME Need to include a pihole uninstaller.

# pivpn ------------------------------------------------------------------- {{{2

koopa_linux_install_pivpn() {
    koopa_update_app \
        --name-fancy='PiVPN' \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}

# FIXME Need to include a pihole uninstaller.
