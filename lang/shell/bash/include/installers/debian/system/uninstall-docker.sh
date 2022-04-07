#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

main() { # {{{1
    # """
    # Uninstall Docker.
    # @note Updated 2021-12-09.
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        'containerd.io'
        'docker-ce'
        'docker-ce-cli'
    )
    koopa_debian_apt_remove "${pkgs[@]}"
    koopa_debian_apt_delete_repo 'docker'
    return 0
}
