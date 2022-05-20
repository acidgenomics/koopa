#!/usr/bin/env bash

koopa_fedora_install_from_rpm() {
    # """
    # Install directly from RPM file.
    # @note Updated 2022-01-28.
    #
    # Allowing passthrough of '--prefix' here.
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [rpm]="$(koopa_fedora_locate_rpm)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[rpm]}" -v \
        --force \
        --install \
        "$@"
    return 0
}
