#!/usr/bin/env bash

koopa::linux_bcbio_run_tests() { # {{{1
    # """
    # Run bcbio unit tests.
    # @note Updated 2020-11-13.
    #
    # See issues regarding unit tests inside Docker images:
    # - https://github.com/bcbio/bcbio-nextgen/issues/3371
    # - https://github.com/bcbio/bcbio-nextgen/issues/3372
    # """
    local git_dir output_dir test tests tools_dir
    tests=(
        'fastrnaseq'
        'star'
        'hisat2'
        'rnaseq'
        'stranded'
        'chipseq'
        'scrnaseq'
    )
    git_dir="${HOME:?}/git/bcbio-nextgen"
    output_dir="${PWD:?}/bcbio-tests"
    tools_dir="$(koopa::bcbio_tools_prefix)"
    while (("$#"))
    do
        case "$1" in
            --git-dir=*)
                git_dir="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --tools-dir=*)
                tools_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "$git_dir" "$tools_dir"
    koopa::mkdir "$output_dir"
    (
        export PATH="${tools_dir}/bin:${PATH}"
        koopa::cd "${git_dir}/tests"
        for test in "${tests[@]}"
        do
            export BCBIO_TEST_DIR="${output_dir}/${test}"
            ./run_tests.sh "$test" --keep-test-dir
        done
    )
    koopa::success 'All unit tests passed.'
    return 0
}

koopa::linux_patch_bcbio() { # {{{1
    # """
    # Patch bcbio.
    # @note Updated 2020-08-13.
    # """
    local bcbio_python git_dir install_dir name_fancy
    koopa::assert_is_installed tee
    koopa::assert_has_no_envs
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
    koopa::h2 'Removing Python cache and compiled pyc files in Git repo.'
    find "$git_dir" -name '*.pyc' -delete
    find "$git_dir" -name '__pycache__' -type d -exec rm -rv {} \;
    koopa::h2 "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa::rm "${install_dir}/anaconda/lib/python"*'/site-packages/bcbio'*
    # Install command must be run relative to our forked git repo.
    # Note the use of absolute path to bcbio_python here.
    (
        koopa::cd "$git_dir"
        koopa::rm 'tests/test_automated_output'
        koopa::h2 "Patching installation via 'setup.py' script."
        "$bcbio_python" setup.py install
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::success "Patching of ${name_fancy} was successful."
    return 0
}
