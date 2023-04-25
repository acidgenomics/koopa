#!/usr/bin/env bash

main() {
    # """
    # Install a Python package as a virtual environment application.
    # @note Updated 2023-04-25.
    #
    # @seealso
    # - https://adamj.eu/tech/2019/03/11/pip-install-from-a-git-repository/
    # """
    local -A app dict
    local -a bin_names man1_names pos
    local bin_name man1_name
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['locate_python']='koopa_locate_python311'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--python-version='*)
                dict['py_maj_ver']="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict['py_maj_ver']="${2:?}"
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
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dict['libexec']="${dict['prefix']}/libexec"
    # NOTE Consider reworking the case-sensitivity edge case handling here.
    case "${dict['name']}" in
        'apache-airflow' | \
        'azure-cli' | \
        'py-spy' | \
        'ranger-fm' | \
        'ruff-lsp' | \
        'yt-dlp')
            dict['pkg_name']="$(koopa_snake_case_simple "${dict['name']}")"
            ;;
        'glances')
            dict['pkg_name']='Glances'
            ;;
        'pygments')
            dict['pkg_name']='Pygments'
            ;;
        'scons')
            dict['pkg_name']='SCons'
            ;;
        *)
            dict['pkg_name']="${dict['name']}"
            ;;
    esac
    dict['py_version']="$(koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        koopa_major_minor_version "${dict['py_version']}" \
    )"
    dict['venv_cmd']="${dict['pkg_name']}==${dict['version']}"
    # Overrides to install from GitHub, for package versions not on PyPi.
# >     case "${dict['pkg_name']}" in
# >         'latch')
# >             case "${dict['version']}" in
# >                 '3.0.0')
# >                     dict['venv_cmd']="${dict['pkg_name']} @ \
# > git+https://github.com/latchbio/latch@${dict['version']}"
# >                     ;;
# >             esac
# >             ;;
# >     esac
    koopa_print_env
    koopa_python_create_venv \
        --prefix="${dict['libexec']}" \
        --python="${app['python']}" \
        "${dict['venv_cmd']}"
    dict['record_file']="${dict['libexec']}/lib/\
python${dict['py_maj_min_ver']}/site-packages/\
${dict['pkg_name']}-${dict['version']}.dist-info/RECORD"
    koopa_assert_is_file "${dict['record_file']}"
    if [[ -f "${dict['record_file']}" ]]
    then
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
# >     else
# >         koopa_alert_note "No record file at '${dict['record_file']}."
# >         bin_names=("${dict['pkg_name']}")
# >         man1_names=()
    fi
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
