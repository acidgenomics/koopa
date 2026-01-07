#!/usr/bin/env bash

koopa_python_script() {
    # """
    # Run a Python script.
    # @note Updated 2026-01-05.
    # """
    local -A app dict
    local -a pos
    koopa_assert_has_args "$#"
    app['python']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
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
    if [[ -z "${app['python']}" ]]
    then
        app['python']="$(koopa_locate_python --allow-bootstrap --allow-system)"
    fi
    koopa_assert_is_installed "${app[@]}"
    dict['prefix']="$(koopa_python_scripts_prefix)"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['cmd_name']="${1:?}"
    shift 1
    dict['script']="${dict['prefix']}/${dict['cmd_name']}"
    koopa_assert_is_executable "${dict['script']}"
    "${app['python']}" "${dict['script']}" "$@"
    return 0
}
