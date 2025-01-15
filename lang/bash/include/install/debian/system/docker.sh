#!/usr/bin/env bash

# FIXME Rework to use this general approach:
# > apt update
# > snap install docker
# > apt install -y docker.io
# > groupadd -f docker
# > usermod -aG docker "$USER"
# > newgrp docker
# > service docker start

main() {
    # """
    # Install Docker.
    # @note Updated 2025-01-15.
    #
    # Currently supports overlay2, aufs and btrfs storage drivers.
    #
    # Configures at '/var/lib/docker/'.
    #
    # @seealso
    # - https://docs.docker.com/install/linux/docker-ce/debian/
    # - https://docs.docker.com/install/linux/docker-ce/ubuntu/
    # - https://stackoverflow.com/questions/45023363
    # """
    local -A app
    local pkgs
    app['service']="$(koopa_debian_locate_service)"
    koopa_assert_is_executable "${app[@]}"
    koopa_debian_apt_add_docker_repo
    pkgs=(
        'containerd.io'
        'docker-buildx-plugin'
        'docker-ce'
        'docker-ce-cli'
        'docker-compose-plugin'
    )
    koopa_debian_apt_install "${pkgs[@]}"
    koopa_linux_add_user_to_group 'docker'
    "${app['service']}" docker start
    return 0
}
