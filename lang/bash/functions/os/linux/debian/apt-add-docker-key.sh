#!/usr/bin/env bash

_koopa_debian_apt_add_docker_key() {
    # """
    # Add the Docker key.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_debian_apt_add_key \
        --name='docker' \
        --url="https://download.docker.com/linux/$(_koopa_os_id)/gpg"
    return 0
}
