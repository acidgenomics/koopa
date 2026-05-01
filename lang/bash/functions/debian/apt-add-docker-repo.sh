#!/usr/bin/env bash

_koopa_debian_apt_add_docker_repo() {
    # """
    # Add Docker apt repo.
    # @note Updated 2023-01-10.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_docker_key
    _koopa_debian_apt_add_repo \
        --component='stable' \
        --distribution="$(_koopa_debian_os_codename)" \
        --name='docker' \
        --url="https://download.docker.com/linux/$(_koopa_os_id)"
    return 0
}
