#!/usr/bin/env bash

koopa_bowtie2_index() {
    # """
    # Generate bowtie2 index.
    # @note Updated 2021-09-21.
    # """
    local app dict index_args
    koopa_assert_has_args "$#"
    koopa_assert_is_installed 'bowtie2-build'
    declare -A app=(
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [threads]="$(koopa_cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa_alert_note \
            "bowtie2 genome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa_h2 "Generating bowtie2 index at '${dict[output_dir]}'."
    koopa_mkdir "${dict[output_dir]}"
    # This step adds 'bowtie2.*' prefix to the files created in the output.
    dict[index_base]="${dict[output_dir]}/bowtie2"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--threads=${dict[threads]}"
        '--verbose'
        "${dict[fasta_file]}"
        "${dict[index_base]}"
    )
    koopa_dl 'Index args' "${index_args[*]}"
    # FIXME Need to locate this directly.
    bowtie2-build "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
