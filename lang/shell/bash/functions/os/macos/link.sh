#!/usr/bin/env bash

# FIXME Rework 'koopa_sys_link' as 'koopa_link_into_bin' instead.

koopa_macos_link_bbedit() { # {{{1
    # """
    # Link BBEdit.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        "$(koopa_koopa_prefix)/bin/bbedit"
    return 0
}

koopa_macos_link_google_cloud_sdk() { # {{{1
    # """
    # Link Google Cloud SDK.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        "$(koopa_homebrew_prefix)/Caskroom/google-cloud-sdk/latest/\
google-cloud-sdk/bin/gcloud" \
        "$(koopa_koopa_prefix)/bin/gcloud"
    return 0
}

koopa_macos_link_julia() { # {{{1
    # """
    # Link Julia.
    # @note Updated 2022-03-31.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [julia_prefix]="$(koopa_macos_julia_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_sys_ln \
        "${dict[julia_prefix]}/bin/julia" \
        "${dict[koopa_prefix]}/bin/julia"
    return 0
}

koopa_macos_link_python() { # {{{1
    # """
    # Link Python.
    # @note Updated 2022-03-30.
    # """
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
    koopa_sys_ln \
        "${app[python]}" \
        "${dict[koopa_prefix]}/bin/python${dict[maj_min_ver]}"
    koopa_sys_ln \
        "${app[python]}" \
        "${dict[koopa_prefix]}/bin/python${dict[maj_ver]}"
    return 0
}

koopa_macos_link_r() { # {{{1
    # """
    # Link R.
    # @note Updated 2022-03-31.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [r_prefix]="$(koopa_macos_r_prefix)"
    )
    koopa_sys_ln \
        "${dict[r_prefix]}/bin/R" \
        "${dict[koopa_prefix]}/bin/R"
    return 0
}

koopa_macos_link_visual_studio_code() { # {{{1
    # """
    # Link Visual Studio Code.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_sys_ln \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        "$(koopa_koopa_prefix)/bin/code"
    return 0
}

koopa_macos_unlink_bbedit() { # {{{1
    # """
    # Unlink BBEdit.
    # @note Updated 2022-03-30.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm "$(koopa_koopa_prefix)/bin/bbedit"
    return 0
}
