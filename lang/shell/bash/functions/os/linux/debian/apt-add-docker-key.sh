#!/usr/bin/env bash

koopa_debian_apt_add_docker_key() {
    # """
    # Add the Docker key.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://docs.docker.com/engine/install/debian/
    # - https://docs.docker.com/engine/install/ubuntu/
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Docker' \
        --name='docker' \
        --url="https://download.docker.com/linux/$(koopa_os_id)/gpg"
    return 0
}
