#!/usr/bin/env bash

koopa_r_script() {
    # """
    # Run an R script.
    # @note Updated 2024-05-28.
    # """
    local -A app bool dict
    local -a pos rscript_cmd
    koopa_assert_has_args "$#"
    app['r']=''
    bool['system']=0
    bool['vanilla']=0
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--r='*)
                app['r']="${1#*=}"
                shift 1
                ;;
            '--r')
                app['r']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--system')
                bool['system']=1
                shift 1
                ;;
            '--vanilla')
                bool['vanilla']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("${1:?}")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    if [[ -z "${app['r']}" ]]
    then
        if [[ "${bool['system']}" -eq 1 ]]
        then
            app['r']="$(koopa_locate_system_r)"
        else
            app['r']="$(koopa_locate_r)"
        fi
    fi
    app['rscript']="${app['r']}script"
    koopa_assert_is_installed "${app[@]}"
    dict['prefix']="$(koopa_r_scripts_prefix)"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['cmd_name']="${1:?}"
    shift 1
    dict['script']="${dict['prefix']}/${dict['cmd_name']}"
    koopa_assert_is_executable "${dict['script']}"
    rscript_cmd+=("${app['rscript']}")
    if [[ "${bool['vanilla']}" -eq 1 ]]
    then
        rscript_cmd+=('--vanilla')
    fi
    "${rscript_cmd[@]}" "${dict['script']}" "$@"
    return 0
}
