#!/usr/bin/env bash

koopa_install_python_package() {
    # """
    # Install a Python package as a virtual environment application.
    # @note Updated 2025-01-17.
    #
    # @seealso
    # - https://adamj.eu/tech/2019/03/11/pip-install-from-a-git-repository/
    # """
    local -A app bool dict
    local -a bin_names extra_pkgs man1_names venv_args
    local bin_name man1_name
    koopa_assert_is_install_subshell
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['binary']=1
    dict['egg_name']=''
    dict['locate_python']='koopa_locate_python312'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['pip_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--egg-name='*)
                dict['egg_name']="${1#*=}"
                shift 1
                ;;
            '--egg-name')
                dict['egg_name']="${2:?}"
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-packages')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--pip-name='*)
                dict['pip_name']="${1#*=}"
                shift 1
                ;;
            '--pip-name')
                dict['pip_name']="${2:?}"
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
            '--python-version='*)
                dict['py_maj_ver']="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict['py_maj_ver']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['egg_name']}" ]] && dict['egg_name']="${dict['name']}"
    [[ -z "${dict['pip_name']}" ]] && dict['pip_name']="${dict['egg_name']}"
    koopa_assert_is_set \
        '--egg-name' "${dict['egg_name']}" \
        '--name' "${dict['name']}" \
        '--pip-name' "${dict['pip_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    if [[ -n "${dict['py_maj_ver']}" ]]
    then
        # e.g. '3.11' to '311'.
        dict['py_maj_ver_2']="$( \
            koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['py_maj_ver']}" \
        )"
        dict['locate_python']="koopa_locate_python${dict['py_maj_ver_2']}"
    fi
    koopa_assert_is_function "${dict['locate_python']}"
    app['python']="$("${dict['locate_python']}" --realpath)"
    koopa_assert_is_executable "${app[@]}"
    koopa_add_to_path_start "$(koopa_parent_dir "${app['python']}")"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['py_version']}" \
    )"
    venv_args=(
        "--prefix=${dict['libexec']}"
        "--python=${app['python']}"
    )
    if [[ "${bool['binary']}" -eq 0 ]]
    then
        venv_args+=('--no-binary')
    fi
    venv_args+=("${dict['pip_name']}==${dict['version']}")
    if koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        venv_args+=("${extra_pkgs[@]}")
    fi
    koopa_print_env
    koopa_python_create_venv "${venv_args[@]}"
    dict['record_file']="${dict['libexec']}/lib/\
python${dict['py_maj_min_ver']}/site-packages/\
${dict['egg_name']}-${dict['version']}.dist-info/RECORD"
    koopa_assert_is_file "${dict['record_file']}"
    # Ensure we exclude any nested subdirectories in libexec bin, which is
    # known to happen with some conda recipes (e.g. bowtie2).
    readarray -t bin_names <<< "$( \
        koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./bin/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '5' \
    )"
    readarray -t man1_names <<< "$( \
        koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./share/man/man1/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '7' \
    )"
    koopa_assert_is_array_non_empty "${bin_names[@]:-}"
    for bin_name in "${bin_names[@]}"
    do
        koopa_ln \
            "${dict['libexec']}/bin/${bin_name}" \
            "${dict['prefix']}/bin/${bin_name}"
    done
    if koopa_is_array_non_empty "${man1_names[@]:-}"
    then
        for man1_name in "${man1_names[@]}"
        do
            koopa_ln \
                "${dict['libexec']}/share/man/man1/${man1_name}" \
                "${dict['prefix']}/share/man/man1/${man1_name}"
        done
    fi
    return 0
}
