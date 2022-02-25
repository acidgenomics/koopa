#!/usr/bin/env bash

koopa::convert_fastq_to_fasta() { # {{{1
    # """
    # Convert FASTQ files into FASTA format.
    # @note Updated 2022-02-16.
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
    # > koopa::convert_fastq_to_fastq \
    # >     --source-dir='fastq/' \
    # >     --target-dir='fasta/'
    # """
    local app dict fastq_file fastq_files
    koopa::assert_has_args "$#"
    declare -A app=(
        [cut]="$(koopa::locate_cut)"
        [paste]="$(koopa::locate_paste)"
        [sed]="$(koopa::locate_sed)"
        [tr]="$(koopa::locate_tr)"
    )
    declare -A dict=(
        [source_dir]="${PWD:?}"
        [target_dir]="${PWD:?}"
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa::realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*.fastq' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files detected in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa::init_dir "${dict[target_dir]}")"
    for fastq_file in "${fastq_files[@]}"
    do
        local fasta_file
        fasta_file="${fastq_file%.fastq}.fasta"
        "${app[paste]}" - - - - < "$fastq_file" \
            | "${app[cut]}" --fields='1,2' \
            | "${app[sed]}" 's/^@/>/' \
            | "${app[tr]}" '\t' '\n' > "$fasta_file"
    done
    return 0
}

koopa::fastq_lanepool() { # {{{1
    # """
    # Pool lane-split FASTQ files.
    # @note Updated 2022-02-16.
    #
    # @examples
    # > koopa::fastq_lanepool --source-dir='fastq/'
    # """
    local app dict
    local basenames head i out tail
    declare -A app=(
        [cat]="$(koopa::locate_cat)"
    )
    declare -A dict=(
        [prefix]='lanepool'
        [source_dir]="${PWD:?}"
        [target_dir]="${PWD:?}"
    )
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
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
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa::realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa::find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*_L001_*.fastq*' \
            --prefix="${dict[source_dir]}" \
            --sort \
            --type='f' \
    )"
    # Error if file array is empty.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa::stop "No lane-split FASTQ files in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa::init_dir "${dict[target_dir]}")"
    basenames=()
    for i in "${fastq_files[@]}"
    do
        basenames+=("$(koopa::basename "$i")")
    done
    head=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001_*/}"
        head+=("$i")
    done
    tail=()
    for i in "${basenames[@]}"
    do
        i="${i//*_L001_/}"
        tail+=("$i")
    done
    out=()
    for i in "${basenames[@]}"
    do
        i="${i//_L001/}"
        i="${dict[target_dir]}/${dict[prefix]}_${i}"
        out+=("$i")
    done
    # Loop across the array indices, similar to 'mapply()' approach in R.
    for i in "${!out[@]}"
    do
        "${app[cat]}" \
            "${dict[source_dir]}/${head[i]}_L00"[1-9]"_${tail[i]}" \
            > "${out[i]}"
    done
    return 0
}

koopa::fastq_reads_per_file() { # {{{1
    # """
    # Determine the number of reads per FASTQ file.
    # @note Updated 2022-02-16.
    #
    # @examples
    # > koopa::fastq_reads_per_file 'fastq/'
    # """
    local app dict
    declare -A app=(
        [awk]="$(koopa::locate_awk)"
        [wc]="$(koopa::locate_wc)"
        [zcat]="$(koopa::locate_zcat)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    dict[prefix]="$(koopa::realpath "${dict[prefix]}")"
    # Divide by 4.
    # shellcheck disable=SC2016
    "${app[zcat]}" "${dict[prefix]}/"*'_R1.fastq.gz' \
        | "${app[wc]}" -l \
        | "${app[awk]}" '{print $1/4}'
    return 0
}
