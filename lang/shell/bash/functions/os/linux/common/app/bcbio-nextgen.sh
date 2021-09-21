#!/usr/bin/env bash

koopa::linux_bcbio_nextgen_run_tests() { # {{{1
    # """
    # Run bcbio-nextgen unit tests.
    # @note Updated 2021-09-21.
    #
    # See issues regarding unit tests inside Docker images:
    # - https://github.com/bcbio/bcbio-nextgen/issues/3371
    # - https://github.com/bcbio/bcbio-nextgen/issues/3372
    # """
    local dict test tests
    declare -A dict=(
        [git_dir]="${HOME:?}/git/bcbio-nextgen"
        [output_dir]="${PWD:?}/bcbio-tests"
        [tools_dir]="$(koopa::bcbio_nextgen_tools_prefix)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--git-dir='*)
                dict[git_dir]="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict[git_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--tools-dir='*)
                dict[tools_dir]="${1#*=}"
                shift 1
                ;;
            '--tools-dir')
                dict[tools_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[git_dir]}" "${dict[tools_dir]}"
    koopa::mkdir "${dict[output_dir]}"
    (
        koopa::add_to_path_start "${dict[tools_dir]}/bin"
        koopa::cd "${dict[git_dir]}/tests"
        tests=(
            'fastrnaseq'
            'star'
            'hisat2'
            'rnaseq'
            'stranded'
            'chipseq'
            'scrnaseq'  # single-cell RNA-seq
            'srnaseq'  # small RNA-seq (hanging inside Docker image)
        )
        for test in "${tests[@]}"
        do
            export BCBIO_TEST_DIR="${dict[output_dir]}/${test}"
            ./run_tests.sh "$test" --keep-test-dir
        done
    )
    koopa::alert_success "Unit tests passed for '${dict[tools_dir]}'."
    return 0
}

koopa::linux_patch_bcbio_nextgen_devel() { # {{{1
    # """
    # Patch bcbio-nextgen development install.
    # @note Updated 2021-09-21
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
            # Key-value pairs --------------------------------------------------
            '--bcbio-python='*)
                dict[bcbio_python]="${1#*=}"
                shift 1
                ;;
            '--bcbio-python')
                dict[bcbio_python]="${2:?}"
                shift 2
                ;;
            '--git-dir='*)
                dict[git_dir]="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict[git_dir]="${2:?}"
                shift 2
                ;;
            '--install-dir='*)
                dict[install_dir]="${1#*=}"
                shift 1
                ;;
            '--install-dir')
                dict[install_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
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
        dict[install_dir]="$(koopa::parent_dir --num=3 "${dict[bcbio_python]}")"
    fi
    koopa::assert_is_dir "${dict[install_dir]}"
    koopa::h1 "Patching ${name_fancy} installation at '${dict[install_dir]}'."
    koopa::dl  \
        'Git dir' "${dict[git_dir]}" \
        'Install dir' "${dict[install_dir]}" \
        'bcbio_python' "${dict[bcbio_python]}"
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
