#!/usr/bin/env bash

koopa::linux_patch_bcbio_devel() { # {{{1
    # """
    # Patch bcbio-nextgen development install.
    # @note Updated 2021-06-11.
    # """
    local cache_files dict name_fancy tee
    koopa::assert_has_no_envs
    declare -A dict=(
        [bcbio_python]=''
        [git_dir]="${HOME:?}/git/bcbio-nextgen"
        [install_dir]=''
    )
    tee="$(koopa::locate_tee)"
    name_fancy='bcbio-nextgen'
    while (("$#"))
    do
        case "$1" in
            --bcbio-python=*)
                dict[bcbio_python]="${1#*=}"
                shift 1
                ;;
            --git-dir=*)
                dict[git_dir]="${1#*=}"
                shift 1
                ;;
            --install-dir=*)
                dict[install_dir]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[git_dir]}"
    if [[ -z "${dict[bcbio_python]}" ]]
    then
        dict[bcbio_python]="$(koopa::which_realpath 'bcbio_python')"
    fi
    koopa::assert_is_executable "${dict[bcbio_python]}"
    if [[ -z "${dict[install_dir]}" ]]
    then
        dict[install_dir]="$(koopa::parent_dir -n 3 "${dict[bcbio_python]}")"
    fi
    koopa::assert_is_dir "${dict[install_dir]}"
    koopa::h1 "Patching ${name_fancy} installation at '${dict[install_dir]}'."
    koopa::dl  \
        'git_dir' "${dict[git_dir]}" \
        'bcbio_python' "${dict[bcbio_python]}" \
        'install_dir' "${dict[install_dir]}"
    koopa::alert "Removing Python cache in '${dict[git_dir]}'."
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='*.pyc' \
            --prefix="${dict[git_dir]}" \
            --type='f'
    )"
    koopa::rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='__pycache__' \
            --prefix="${dict[git_dir]}" \
            --type='d'
    )"
    koopa::rm "${cache_files[@]}"
    koopa::alert "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa::rm "${dict[install_dir]}/anaconda/lib/python"*'/site-packages/bcbio'*
    (
        koopa::cd "${dict[git_dir]}"
        koopa::rm 'tests/test_automated_output'
        koopa::alert "Patching installation via 'setup.py' script."
        "${dict[bcbio_python]}" setup.py install
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::alert_success "Patching of ${name_fancy} was successful."
    return 0
}
