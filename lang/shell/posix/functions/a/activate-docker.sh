#!/bin/sh

_koopa_activate_docker() {
    # """
    # Activate Docker.
    # @note Updated 2023-05-01.
    #
    # @seealso
    # - https://docs.docker.com/engine/release-notes/23.0/
    # """
    _koopa_add_to_path_start "${HOME:?}/docker/bin"
    return 0
}
