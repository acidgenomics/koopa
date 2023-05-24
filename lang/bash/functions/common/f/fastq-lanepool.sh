#!/usr/bin/env bash

koopa_fastq_lanepool() {
    # """
    # Pool lane-split FASTQ files.
    # @note Updated 2023-05-24.
    #
    # @examples
    # > koopa_fastq_lanepool \
    # >     --source-dir='fastq' \
    # >     --target-dir='fastq-lanepool'
    # """
    local -A app dict
    local -a bns fastq_files head out tail
    local bn file i
    app['cat']="$(koopa_locate_cat --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']='lanepool'
    dict['source_dir']=''
    dict['target_dir']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            '--target-dir='*)
                dict['target_dir']="${1#*=}"
                shift 1
                ;;
            '--target-dir')
                dict['target_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--source-dir' "${dict['source_dir']}" \
        '--target-dir' "${dict['target_dir']}"
    koopa_assert_is_dir "${dict['source_dir']}"
    dict['source_dir']="$(koopa_realpath "${dict['source_dir']}")"
    readarray -t fastq_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern='*_L001_*.fastq*' \
            --prefix="${dict['source_dir']}" \
            --sort \
            --type='f' \
    )"
    # Error if file array is empty.
    if [[ "${#fastq_files[@]}" -eq 0 ]]
    then
        koopa_stop "No lane-split FASTQ files in '${dict['source_dir']}'."
    fi
    dict['target_dir']="$(koopa_init_dir "${dict['target_dir']}")"
    for file in "${fastq_files[@]}"
    do
        bns+=("$(koopa_basename "$file")")
    done
    for bn in "${bns[@]}"
    do
        head+=("${bn//_L001_*/}")
        tail+=("${bn//*_L001_/}")
        out+=("${dict['target_dir']}/${dict['prefix']}_${bn//_L001/}")
    done
    for i in "${!fastq_files[@]}"
    do
        "${app['cat']}" \
            "${dict['source_dir']}/${head[$i]}_L"*"_${tail[$i]}" \
            > "${out[$i]}"
    done
    return 0
}
