#!/usr/bin/env bash

koopa_debian_apt_add_docker_repo() {
    # """
    # Add Docker apt repo.
    # @note Updated 2022-07-15.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_docker_key
    koopa_debian_apt_add_repo \
        --component='stable' \
        --distribution="$(koopa_os_codename)" \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa_os_id)"
    return 0
}
