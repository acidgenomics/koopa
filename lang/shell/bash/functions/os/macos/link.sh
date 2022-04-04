#!/usr/bin/env bash

koopa_macos_link_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    return 0
}

koopa_macos_link_google_cloud_sdk() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        "$(koopa_homebrew_prefix)/Caskroom/google-cloud-sdk/latest/\
google-cloud-sdk/bin/gcloud" \
        'gcloud'
    return 0
}

koopa_macos_link_julia() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [julia_prefix]="$(koopa_macos_julia_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_link_in_bin \
        "${dict[julia_prefix]}/bin/julia" \
        'julia'
    return 0
}

koopa_macos_link_python() { # {{{1
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [find]="$(koopa_locate_find)"
    )
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [python_prefix]="$(koopa_macos_python_prefix)"
    )
    app[python]="$( \
        "${app[find]}" \
            "${dict[python_prefix]}/bin" \
            -type 'f' \
            -executable \
            -name 'python*' \
            -not -name '*-*' \
    )"
    koopa_assert_is_executable "${app[python]}"
    dict[version]="$(koopa_get_version "${app[python]}")"
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    koopa_link_in_bin \
        "${app[python]}" "python${dict[maj_min_ver]}" \
        "${app[python]}" "python${dict[maj_ver]}"
    return 0
}

koopa_macos_link_r() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [r_prefix]="$(koopa_macos_r_prefix)"
    )
    koopa_link_in_bin \
        "${dict[r_prefix]}/bin/R" 'R' \
        "${dict[r_prefix]}/bin/Rscript" 'Rscript'
    return 0
}

koopa_macos_link_visual_studio_code() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
    return 0
}

koopa_macos_unlink_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'bbedit'
    return 0
}
