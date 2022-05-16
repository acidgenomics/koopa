#!/usr/bin/env bash

# FIXME Consider just running these inside the uninstall call.

koopa_unlink_google_cloud_sdk() {
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'gcloud'
    return 0
}

koopa_unlink_julia() {
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'julia'
    return 0
}

koopa_unlink_python() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [version]="${1:-}"
    )
    if [[ -z "${dict[version]}" ]]
    then
        dict[version]="$(koopa_variable 'python')"
    fi
    dict[maj_min_ver]="$(koopa_major_version "${dict[version]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_unlink_in_bin \
        "python${dict[maj_min_ver]}" \
        "python${dict[maj_ver]}"
    return 0
}

koopa_unlink_r() {
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'R' 'Rscript'
    return 0
}

koopa_unlink_visual_studio_code() {
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'code'
    return 0
}
