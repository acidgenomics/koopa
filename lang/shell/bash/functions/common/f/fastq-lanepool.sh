#!/usr/bin/env bash

koopa_fastq_lanepool() {
    # """
    # Pool lane-split FASTQ files.
    # @note Updated 2022-03-25.
    #
    # @examples
    # > koopa_fastq_lanepool --source-dir='fastq/'
    # """
    local app basenames dict fastq_files head i out tail
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[source_dir]}"
    dict[source_dir]="$(koopa_realpath "${dict[source_dir]}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
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
        koopa_stop "No lane-split FASTQ files in '${dict[source_dir]}'."
    fi
    dict[target_dir]="$(koopa_init_dir "${dict[target_dir]}")"
    basenames=()
    for i in "${fastq_files[@]}"
    do
        basenames+=("$(koopa_basename "$i")")
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
