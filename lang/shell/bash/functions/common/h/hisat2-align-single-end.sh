#!/usr/bin/env bash

koopa_hisat2_align_single_end() {
    # """
    # Run HISAT2 aligner on multiple single-end FASTQs in a directory.
    # @note Updated 2022-03-25.
    #
    # > koopa_hisat2_align_single_end \
    # >     --fastq-dir='fastq' \
    # >     --fastq-tail='.fastq.gz' \
    # >     --index-dir='hisat2-index' \
    # >     --output-dir='hisat2'
    # """
    local dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A dict=(
        # e.g. 'fastq'
        [fastq_dir]=''
        # e.g. '.fastq.gz'
        [fastq_tail]=''
        # e.g. 'hisat2-index'.
        [index_dir]=''
        # Using salmon fragment library type conventions here.
        [lib_type]='A'
        [mode]='single-end'
        # e.g. 'hisat2'.
        [output_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-dir='*)
                dict[fastq_dir]="${1#*=}"
                shift 1
                ;;
            '--fastq-dir')
                dict[fastq_dir]="${2:?}"
                shift 2
                ;;
            '--fastq-tail='*)
                dict[fastq_tail]="${1#*=}"
                shift 1
                ;;
            '--fastq-tail')
                dict[fastq_tail]="${2:?}"
                shift 2
                ;;
            '--index-dir='*)
                dict[index_dir]="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict[index_dir]="${2:?}"
                shift 2
                ;;
            '--lib-type='*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            '--lib-type')
                dict[lib_type]="${2:?}"
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
    koopa_assert_is_set \
        '--fastq-dir' "${dict[fastq_dir]}" \
        '--fastq-tail' "${dict[fastq_tail]}" \
        '--index-dir' "${dict[index_dir]}" \
        '--lib-type' "${dict[lib_type]}" \
        '--output-dir' "${dict[output_dir]}"
    koopa_assert_is_dir "${dict[fastq_dir]}" "${dict[index_dir]}"
    dict[fastq_dir]="$(koopa_realpath "${dict[fastq_dir]}")"
    dict[index_dir]="$(koopa_realpath "${dict[index_dir]}")"
    dict[output_dir]="$(koopa_init_dir "${dict[output_dir]}")"
    koopa_h1 'Running HISAT2 aligner.'
    koopa_dl \
        'Mode' "${dict[mode]}" \
        'Index dir' "${dict[index_dir]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'FASTQ tail' "${dict[fastq_tail]}" \
        'Output dir' "${dict[output_dir]}"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*${dict[fastq_tail]}" \
            --prefix="${dict[fastq_dir]}" \
            --sort \
            --type='f' \
    )"
    if koopa_is_array_empty "${fastq_files[@]:-}"
    then
        koopa_stop "No FASTQs ending with '${dict[fastq_tail]}'."
    fi
    koopa_alert_info "$(koopa_ngettext \
        --num="${#fastq_files[@]}" \
        --msg1='sample' \
        --msg2='samples' \
        --suffix=' detected.' \
    )"
    for fastq_file in "${fastq_files[@]}"
    do
        koopa_hisat2_align_single_end_per_sample \
            --fastq-file="$fastq_file" \
            --fastq-tail="${dict[fastq_tail]}" \
            --index-dir="${dict[index_dir]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}"
    done
    koopa_alert_success 'HISAT2 alignment was successful.'
    return 0
}
