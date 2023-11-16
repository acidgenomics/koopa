#!/usr/bin/env bash

koopa_linux_bcbio_nextgen_patch_devel() {
    # """
    # Patch bcbio-nextgen development install.
    # @note Updated 2023-04-05.
    # """
    local -A app dict
    local -a cache_files
    koopa_assert_has_no_envs
    app['bcbio_python']="$(koopa_linux_locate_bcbio_python)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['git_dir']="${HOME:?}/git/bcbio-nextgen"
    dict['install_dir']=''
    dict['name']='bcbio-nextgen'
    dict['tmp_log_file']="$(koopa_tmp_log_file)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bcbio-python='*)
                app['bcbio_python']="${1#*=}"
                shift 1
                ;;
            '--bcbio-python')
                app['bcbio_python']="${2:?}"
                shift 2
                ;;
            '--git-dir='*)
                dict['git_dir']="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict['git_dir']="${2:?}"
                shift 2
                ;;
            '--install-dir='*)
                dict['install_dir']="${1#*=}"
                shift 1
                ;;
            '--install-dir')
                dict['install_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['git_dir']}"
    if [[ -z "${dict['install_dir']}" ]]
    then
        dict['install_dir']="$( \
            koopa_parent_dir --num=3 "${app['bcbio_python']}" \
        )"
    fi
    koopa_assert_is_dir "${dict['install_dir']}"
    koopa_h1 "Patching '${dict['name']}' installation \
at '${dict['install_dir']}'."
    koopa_dl  \
        'Git dir' "${dict['git_dir']}" \
        'Install dir' "${dict['install_dir']}" \
        'bcbio_python' "${app['bcbio_python']}"
    koopa_alert "Removing Python cache in '${dict['git_dir']}'."
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='*.pyc' \
            --prefix="${dict['git_dir']}" \
            --type='f'
    )"
    koopa_rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='__pycache__' \
            --prefix="${dict['git_dir']}" \
            --type='d'
    )"
    koopa_rm "${cache_files[@]}"
    koopa_alert "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa_rm "${dict['install_dir']}/anaconda/lib/python"*'/\
site-packages/bcbio'*
    # FIXME May need to rework the tee call here.
    (
        koopa_cd "${dict['git_dir']}"
        koopa_rm 'tests/test_automated_output'
        koopa_alert "Patching installation via 'setup.py' script."
        "${app['bcbio_python']}" setup.py install
    ) 2>&1 | "${app['tee']}" "${dict['tmp_log_file']}"
    koopa_alert_success "Patching of '${dict['name']}' was successful."
    return 0
}
