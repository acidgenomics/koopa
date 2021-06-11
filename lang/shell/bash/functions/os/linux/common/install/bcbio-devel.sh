#!/usr/bin/env bash

koopa::linux_patch_bcbio_devel() { # {{{1
    # """
    # Patch bcbio.
    # @note Updated 2021-05-20.
    # """
    local bcbio_python cache_files git_dir install_dir name_fancy tee
    koopa::assert_has_no_envs
    tee="$(koopa::locate_tee)"
    name_fancy='bcbio-nextgen'
    while (("$#"))
    do
        case "$1" in
            --bcbio-python=*)
                bcbio_python="${1#*=}"
                shift 1
                ;;
            --git-dir=*)
                git_dir="${1#*=}"
                shift 1
                ;;
            --install-dir=*)
                install_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Locate bcbio git directory.
    if [[ -z "${git_dir:-}" ]]
    then
        git_dir="${HOME}/git/bcbio-nextgen"
    fi
    koopa::assert_is_dir "$git_dir"
    # Locate bcbio python.
    if [[ -z "${bcbio_python:-}" ]]
    then
        bcbio_python="$(koopa::which_realpath 'bcbio_python')"
    fi
    koopa::assert_is_executable "$bcbio_python"
    # Locate bcbio installation directory.
    if [[ -z "${install_dir:-}" ]]
    then
        install_dir="$(koopa::cd "$(dirname "$bcbio_python")/../.." && pwd -P)"
    fi
    koopa::assert_is_dir "$install_dir"
    koopa::h1 "Patching ${name_fancy} installation."
    koopa::dl 'git_dir' "$git_dir"
    koopa::dl 'bcbio_python' "$bcbio_python"
    koopa::dl 'install_dir' "$install_dir"
    koopa::alert 'Removing Python cache and compiled pyc files in Git repo.'
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='*.pyc' \
            --prefix="$git_dir" \
            --type='f'
    )"
    koopa::rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='__pycache__' \
            --prefix="$git_dir" \
            --type='d'
    )"
    koopa::rm "${cache_files[@]}"
    koopa::h2 "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa::rm "${install_dir}/anaconda/lib/python"*'/site-packages/bcbio'*
    # Install command must be run relative to our forked git repo.
    # Note the use of absolute path to bcbio_python here.
    (
        koopa::cd "$git_dir"
        koopa::rm 'tests/test_automated_output'
        koopa::alert "Patching installation via 'setup.py' script."
        "$bcbio_python" setup.py install
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::alert_success "Patching of ${name_fancy} was successful."
    return 0
}
