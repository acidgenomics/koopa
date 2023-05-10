#!/usr/bin/env bash

koopa_r_copy_files_into_etc() {
    # """
    # Copy R config files into 'etc/'.
    # @note Updated 2023-05-10.
    #
    # Don't copy Makevars file across machines.
    # """
    local -A app dict
    local -a files
    local file
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['r_etc_source']="$(koopa_koopa_prefix)/etc/R"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['sudo']=0
    dict['version']="$(koopa_r_version "${app['r']}")"
    koopa_assert_is_dir \
        "${dict['r_etc_source']}" \
        "${dict['r_prefix']}"
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
    files=('Rprofile.site' 'repositories')
    for file in "${files[@]}"
    do
        if [[ "${dict['sudo']}" -eq 1 ]]
        then
            koopa_cp --sudo \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        else
            koopa_cp \
                "${dict['r_etc_source']}/${file}" \
                "${dict['r_etc_target']}/${file}"
        fi
    done
    return 0
}
