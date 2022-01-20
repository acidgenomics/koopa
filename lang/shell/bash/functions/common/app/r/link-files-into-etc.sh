#!/usr/bin/env bash

koopa::r_link_files_into_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2022-01-20.
    #
    # Don't copy Makevars file across machines.
    # """
    local app dict file files
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa::locate_r)"
    koopa::assert_is_installed "${app[r]}"
    app[r]="$(koopa::which_realpath "${app[r]}")"
    declare -A dict=(
        [distro_prefix]="$(koopa::distro_prefix)"
        [r_prefix]="$(koopa::r_prefix "${app[r]}")"
        [version]="$(koopa::r_version "${app[r]}")"
    )
    koopa::assert_is_dir "${dict[r_prefix]}"
    if [[ "${dict[version]}" != 'devel' ]]
    then
        dict[version]="$(koopa::major_minor_version "${dict[version]}")"
    fi
    dict[r_etc_source]="${dict[distro_prefix]}/etc/R/${dict[version]}"
    koopa::assert_is_dir "${dict[r_etc_source]}"
    if koopa::is_linux && \
        ! koopa::is_koopa_app "${app[r]}" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        dict[r_etc_target]='/etc/R'
    else
        dict[r_etc_target]="${dict[r_prefix]}/etc"
    fi
    files=(
        'Makevars.site'  # macOS
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${dict[r_etc_source]}/${dict[file]}" ]] || continue
        koopa::sys_ln \
            "${dict[r_etc_source]}/${dict[file]}" \
            "${dict[r_etc_target]}/${dict[file]}"
    done
    return 0
}
