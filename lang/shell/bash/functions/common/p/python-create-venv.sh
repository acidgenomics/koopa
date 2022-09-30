#!/usr/bin/env bash

koopa_python_create_venv() {
    # """
    # Create Python virtual environment.
    # @note Updated 2022-09-30.
    #
    # In the future, consider adding support for 'requirements.txt' input.
    #
    # @seealso
    # - https://docs.python.org/3/library/venv.html
    # - https://github.com/Homebrew/brew/blob/master/docs/
    #     Python-for-Formula-Authors.md
    #
    # @examples
    # > koopa_python_create_venv --name='pandas' 'pandas'
    # """
    local app dict pkgs pos venv_args
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        ['python']="$(koopa_locate_python)"
    )
    [[ -x "${app['python']}" ]] || return 1
    # This helps improve path definition in 'pyvenv.cfg' output file.
    app['python']="$(koopa_realpath "${app['python']}")"
    declare -A dict=(
        ['name']=''
        ['pip']=1
        ['prefix']=''
        ['system_site_packages']=1
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    pkgs=("$@")
    koopa_assert_is_set --python "${app['python']}"
    koopa_assert_is_installed "${app['python']}"
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$(koopa_major_minor_version "${dict['py_version']}")"
    if [[ -z "${dict['prefix']}" ]]
    then
        koopa_assert_is_set --name "${dict['name']}"
        dict['venv_prefix']="$(koopa_python_virtualenvs_prefix)"
        dict['prefix']="${dict['venv_prefix']}/${dict['name']}"
        dict['app_bn']="$(koopa_basename "${dict['venv_prefix']}")"
        dict['app_prefix']="$(koopa_app_prefix)/${dict['app_bn']}/\
${dict['py_maj_min_ver']}"
        if [[ ! -d "${dict['app_prefix']}" ]]
        then
            koopa_alert "Configuring venv prefix at '${dict['app_prefix']}'."
            koopa_sys_mkdir "${dict['app_prefix']}"
            koopa_sys_set_permissions "$(koopa_dirname "${dict['app_prefix']}")"
        fi
        koopa_link_in_opt \
            --name="${dict['app_bn']}" \
            --source="${dict['app_prefix']}"
    fi
    [[ -d "${dict['prefix']}" ]] && koopa_rm "${dict['prefix']}"
    koopa_assert_is_not_dir "${dict['prefix']}"
    koopa_sys_mkdir "${dict['prefix']}"
    unset -v PYTHONPATH
    venv_args=()
    if [[ "${dict['pip']}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${dict['system_site_packages']}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict['prefix']}")
    "${app['python']}" -m venv "${venv_args[@]}"
    app['venv_python']="${dict['prefix']}/bin/python${dict['py_maj_min_ver']}"
    koopa_assert_is_installed "${app['venv_python']}"
    if [[ "${dict['pip']}" -eq 1 ]]
    then
        case "${dict['py_version']}" in
            '3.10.'*)
                # 2022-09-30.
                dict['pip_version']='22.2.2'
                dict['setuptools_version']='65.4.1'
                dict['wheel_version']='0.37.1'
                ;;
            *)
                koopa_stop "Unsupported Python: ${dict['py_version']}."
                ;;
        esac
        koopa_python_pip_install \
            --python="${app['venv_python']}" \
            "pip==${dict['pip_version']}" \
            "setuptools==${dict['setuptools_version']}" \
            "wheel==${dict['wheel_version']}"
    fi
    if koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        koopa_python_pip_install --python="${app['venv_python']}" "${pkgs[@]}"
    fi
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    return 0
}
