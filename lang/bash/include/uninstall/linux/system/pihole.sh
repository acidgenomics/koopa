#!/usr/bin/env bash

main() {
    # """
    # Uninstall pihole.
    # @note Updated 2023-05-22.
    #
    # @seealso
    # - https://docs.pi-hole.net/main/uninstall/
    # """
    local -A app
    app['pihole']="$(koopa_linux_locate_pihole)"
    koopa_assert_is_executable "${app[@]}"
    "${app['pihole']}" uninstall
    return 0
}
