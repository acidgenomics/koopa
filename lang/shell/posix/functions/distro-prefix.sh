#!/bin/sh

koopa_distro_prefix() {
    # """
    # Operating system distro prefix.
    # @note Updated 2022-01-27.
    # """
    local koopa_prefix os_id prefix
    koopa_prefix="$(koopa_koopa_prefix)"
    os_id="$(koopa_os_id)"
    if koopa_is_linux
    then
        prefix="${koopa_prefix}/os/linux/${os_id}"
    else
        prefix="${koopa_prefix}/os/${os_id}"
    fi
    koopa_print "$prefix"
    return 0
}
