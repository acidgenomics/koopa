#!/usr/bin/env bash

koopa_locate_gcc() {
    local dict
    declare -A dict=(
        [name]='gcc'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_locate_app \
        --allow-in-path \
        --app-name="${dict[name]}-${dict[maj_ver]}" \
        --opt-name="${dict[name]}@${dict[maj_ver]}"
}
