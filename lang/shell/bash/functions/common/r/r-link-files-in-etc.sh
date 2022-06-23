#!/usr/bin/env bash

koopa_r_link_files_in_etc() {
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2022-06-15.
    #
    # Don't copy Makevars file across machines.
    # """
    local app dict file files
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${app[r]}"
    app[r]="$(koopa_realpath "${app[r]}")"
    declare -A dict=(
        [distro_prefix]="$(koopa_distro_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [sudo]=0
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    if [[ "${dict[version]}" != 'devel' ]]
    then
        dict[version]="$(koopa_major_minor_version "${dict[version]}")"
    fi
    dict[r_etc_source]="${dict[distro_prefix]}/etc/R/${dict[version]}"
    koopa_assert_is_dir "${dict[r_etc_source]}"
    if koopa_is_linux && \
        ! koopa_is_koopa_app "${app[r]}" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        dict[r_etc_target]='/etc/R'
        dict[sudo]=1
    else
        dict[r_etc_target]="${dict[r_prefix]}/etc"
    fi
    files=(
        'Makevars.site' # macOS
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${dict[r_etc_source]}/${file}" ]] || continue
        if [[ "${dict[sudo]}" -eq 1 ]]
        then
            koopa_ln --sudo \
                "${dict[r_etc_source]}/${file}" \
                "${dict[r_etc_target]}/${file}"
        else
            koopa_sys_ln \
                "${dict[r_etc_source]}/${file}" \
                "${dict[r_etc_target]}/${file}"
        fi
    done
    return 0
}
