#!/usr/bin/env bash

koopa_convert_fastq_to_fasta() {
    # """
    # Convert FASTQ files into FASTA format.
    # @note Updated 2022-03-25.
    #
    # Files must be decompressed.
    #
    # @section Alternate approaches:
    #
    # > seqtk seq -A
    # > bioawk -c fastx '{print ">" $name; print $seq}' "$fastq_file"
    # > cat "$fastq_file" \
    # >     | paste - - - - \
    # >     | awk -v FS="\t" '{print $1"\n"$2}' \
    # >     > "$fasta_file"
    #
    # @examples
    # > koopa_convert_fastq_to_fastq \
    # >     --source-dir='fastq/' \
    # >     --target-dir='fasta/'
    # """
    local app dict fastq_file fastq_files
    koopa_assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [paste]="$(koopa_locate_paste)"
        [sed]="$(koopa_locate_sed)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        [source_dir]=''
        [target_dir]=''
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--source-dir='*)
                dict[source_dir]="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict[source_dir]="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict[target_dir]="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict[target_dir]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--source-dir' "${dict[source_dir]}" \
        '--target-dir' "${dict[target_dir]}"
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No FASTQ files detected in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app[paste]}" - - - - < "$fastq_file" \
            | "${app[cut]}" -f '1,2' \
            | "${app[sed]}" 's/^@/>/' \
            | "${app[tr]}" '\t' '\n' > "$fasta_file"
    done
    return 0
}
