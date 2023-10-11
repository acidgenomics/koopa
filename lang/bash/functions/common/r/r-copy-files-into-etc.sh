#!/usr/bin/env bash

koopa_r_copy_files_into_etc() {
    # """
    # Copy R config files into 'etc/'.
    # @note Updated 2023-07-12.
    #
    # Don't copy Makevars file across machines.
    # """
    local -A app bool dict
    local -a files
    local file
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    koopa_warn "FIXME SYSTEM: ${bool['system']}"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    dict['r_etc_source']="$(koopa_koopa_prefix)/etc/R"
    dict['r_etc_target']="${dict['r_prefix']}/etc"
    koopa_assert_is_dir \
        "${dict['r_etc_source']}" \
        "${dict['r_etc_target']}" \
        "${dict['r_prefix']}"
    files=('Rprofile.site' 'repositories')
    for file in "${files[@]}"
    do
        local -A dict2
        dict2['source']="${dict['r_etc_source']}/${file}"
        dict2['target']="${dict['r_etc_target']}/${file}"
        koopa_assert_is_file "${dict2['source']}"
        if [[ -L "${dict2['target']}" ]]
        then
            dict2['realtarget']="$(koopa_realpath "${dict2['target']}")"
            if [[ "${dict2['realtarget']}" == "/etc/R/${file}" ]]
            then
                dict2['target']="${dict2['realtarget']}"
            fi
        fi
        koopa_alert "Modifying '${dict2['target']}'."
        if [[ "${bool['system']}" -eq 1 ]]
        then
            koopa_cp --sudo "${dict2['source']}" "${dict2['target']}"
        else
            koopa_cp "${dict2['source']}" "${dict2['target']}"
        fi
    done
    return 0
}
