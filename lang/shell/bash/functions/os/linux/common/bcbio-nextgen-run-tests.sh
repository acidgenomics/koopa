#!/usr/bin/env bash

koopa_linux_bcbio_nextgen_run_tests() {
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
        [tools_dir]="$(koopa_bcbio_nextgen_tools_prefix)"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[git_dir]}" "${dict[tools_dir]}"
    koopa_mkdir "${dict[output_dir]}"
    (
        koopa_add_to_path_start "${dict[tools_dir]}/bin"
        koopa_cd "${dict[git_dir]}/tests"
        tests=(
            'fastrnaseq'
            'star'
            'hisat2'
            'rnaseq'
            'stranded'
            'chipseq'
            'scrnaseq' # single-cell RNA-seq.
            'srnaseq' # small RNA-seq (hanging inside Docker image).
        )
        for test in "${tests[@]}"
        do
            export BCBIO_TEST_DIR="${dict[output_dir]}/${test}"
            ./run_tests.sh "$test" --keep-test-dir
        done
    )
    koopa_alert_success "Unit tests passed for '${dict[tools_dir]}'."
    return 0
}
