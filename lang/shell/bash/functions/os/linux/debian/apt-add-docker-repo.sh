#!/usr/bin/env bash

koopa_debian_apt_add_docker_repo() {
    # """
    # Add Docker apt repo.
    # @note Updated 2023-01-10.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_docker_key
    koopa_debian_apt_add_repo \
        --component='stable' \
        --distribution="$(koopa_debian_os_codename)" \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa_os_id)"
    return 0
}
