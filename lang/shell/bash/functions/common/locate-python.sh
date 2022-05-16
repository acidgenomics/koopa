#!/usr/bin/env bash

koopa_locate_python() {
    local dict
    declare -A dict=(
        [name]='python'
    )
    dict[version]="$(koopa_variable "${dict[name]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[python]="${dict[name]}${dict[maj_ver]}"
    koopa_locate_app \
        --app-name="${dict[python]}" \
        --opt-name='python'
}
