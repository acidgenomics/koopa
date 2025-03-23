#!/usr/bin/env bash

main() {
    # """
    # Uninstall Docker.
    # @note Updated 2025-01-15.
    # """
    local -a pkgs
    pkgs=(
        # Official packages ----
        'containerd.io'
        'docker-buildx-plugin'
        'docker-ce'
        'docker-ce-cli'
        'docker-compose-plugin'
        # Conflicting packages ----
        'containerd'
        'docker-compose'
        'docker-doc'
        'docker.io'
        'podman-docker'
        'runc'
    )
    koopa_debian_apt_remove "${pkgs[@]}" || true
    koopa_debian_apt_delete_repo 'docker'
    return 0
}
