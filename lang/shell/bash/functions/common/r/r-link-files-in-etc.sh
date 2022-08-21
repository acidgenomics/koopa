#!/usr/bin/env bash

# FIXME Simpliy this, to take out platform-specific files.
# In this case, we need to write them per machine.

koopa_r_link_files_in_etc() {
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2022-07-28.
    #
    # Don't copy Makevars file across machines.
    # """
    local app dict file files
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
    )
    [[ -x "${app['r']}" ]] || return 1
    declare -A dict=(
        [r_etc_source]="$(koopa_koopa_prefix)/etc/R"
        [r_prefix]="$(koopa_r_prefix "${app['r']}")"
        [sudo]=0
        [version]="$(koopa_r_version "${app['r']}")"
    )
    koopa_assert_is_dir "${dict['r_etc_source']}" "${dict['r_prefix']}"
    if koopa_is_linux && \
        ! koopa_is_koopa_app "${app['r']}" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        dict['r_etc_target']='/etc/R'
        dict['sudo']=1
    else
        dict['r_etc_target']="${dict['r_prefix']}/etc"
    fi
    files=(
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        if [[ "${dict['sudo']}" -eq 1 ]]
        then
            koopa_ln --sudo \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        else
            koopa_sys_ln \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        fi
    done
    return 0
}
