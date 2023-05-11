#!/usr/bin/env bash

koopa_r_copy_files_into_etc() {
    # """
    # Copy R config files into 'etc/'.
    # @note Updated 2023-05-11.
    #
    # Don't copy Makevars file across machines.
    # """
    local -A app dict
    local -a files
    local file
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    dict['system']=0
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    dict['r_etc_source']="$(koopa_koopa_prefix)/etc/R"
    dict['r_etc_target']="${dict['r_prefix']}/etc"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['version']="$(koopa_r_version "${app['r']}")"
    koopa_assert_is_dir \
        "${dict['r_etc_source']}" \
        "${dict['r_prefix']}"
    # This applies to Debian/Ubuntu CRAN binary installs.
    if koopa_is_linux && \
        [[ "${dict['system']}" -eq 1 ]] && \
        [[ -d '/etc/R' ]]
    then
        dict['r_etc_target']='/etc/R'
    fi
    files=('Rprofile.site' 'repositories')
    for file in "${files[@]}"
    do
        if [[ "${dict['system']}" -eq 1 ]]
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
