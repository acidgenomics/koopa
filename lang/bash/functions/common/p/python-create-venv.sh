#!/usr/bin/env bash

koopa_python_create_venv() {
    # """
    # Create Python virtual environment.
    # @note Updated 2023-05-16.
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
    local -A app bool dict
    local -a pip_args pkgs pos venv_args
    local pkg
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    app['python']=''
    bool['binary']=1
    bool['pip']=1
    bool['system_site_packages']=1
    dict['name']=''
    dict['prefix']=''
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
            # Flags ------------------------------------------------------------
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            '--without-pip')
                bool['pip']=0
                shift 1
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
    [[ -z "${app['python']}" ]] && \
        app['python']="$(koopa_locate_python311 --realpath)"
    koopa_assert_is_set --python "${app['python']}"
    koopa_assert_is_installed "${app['python']}"
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['py_version']}" \
    )"
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
    if [[ "${bool['pip']}" -eq 0 ]]
    then
        venv_args+=('--without-pip')
    fi
    if [[ "${bool['system_site_packages']}" -eq 1 ]]
    then
        venv_args+=('--system-site-packages')
    fi
    venv_args+=("${dict['prefix']}")
    "${app['python']}" -m venv "${venv_args[@]}"
    app['venv_python']="${dict['prefix']}/bin/python${dict['py_maj_min_ver']}"
    koopa_assert_is_installed "${app['venv_python']}"
    if [[ "${bool['pip']}" -eq 1 ]]
    then
        case "${dict['py_version']}" in
            '3.11.'* | \
            '3.10.'* | \
            '3.9.'*)
                # 2023-05-16.
                dict['pip_version']='23.1.2'
                dict['setuptools_version']='67.7.2'
                dict['wheel_version']='0.40.0'
                ;;
            *)
                koopa_stop "Unsupported Python: ${dict['py_version']}."
                ;;
        esac
        pip_args=(
            "--python=${app['venv_python']}"
            "pip==${dict['pip_version']}"
            "setuptools==${dict['setuptools_version']}"
            "wheel==${dict['wheel_version']}"
        )
        koopa_python_pip_install "${pip_args[@]}"
    fi
    if koopa_is_array_non_empty "${pkgs[@]:-}"
    then
        pip_args=("--python=${app['venv_python']}")
        if [[ "${bool['binary']}" -eq 0 ]]
        then
            app['cut']="$(koopa_locate_cut --allow-system)"
            koopa_assert_is_executable "${app['cut']}"
            for pkg in "${pkgs[@]}"
            do
                local pkg_name
                pkg_name="$(koopa_print "$pkg" | "${app['cut']}" -d '=' -f 1)"
                pip_args+=("--no-binary=$pkg_name")
            done
        fi
        pip_args+=("${pkgs[@]}")
        koopa_python_pip_install "${pip_args[@]}"
    fi
    koopa_sys_set_permissions --recursive "${dict['prefix']}"
    return 0
}