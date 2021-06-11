#!/usr/bin/env bash

koopa::linux_bcbio_run_tests() { # {{{1
    # """
    # Run bcbio unit tests.
    # @note Updated 2020-12-01.
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
        'scrnaseq'  # single-cell RNA-seq
        'srnaseq'  # small RNA-seq (hanging inside Docker image)
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
    koopa::alert_success 'All unit tests passed.'
    return 0
}
