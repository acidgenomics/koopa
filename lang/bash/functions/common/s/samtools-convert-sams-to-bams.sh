#!/usr/bin/env bash

koopa_samtools_convert_sams_to_bams() {
    # """
    # Convert multiple SAM files in a directory to BAM files.
    # @note Updated 2023-10-20.
    # """
    local -A bool dict
    local -a pos sam_files
    local sam_file
    bool['keep_sam']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep-sam')
                bool['keep_sam']=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_eq "$#" 1
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    dict['prefix']="$(koopa_realpath "${dict['prefix']}")"
    readarray -t sam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.sam' \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${sam_files[@]:-}"
    then
        koopa_stop "No SAM files detected in '${dict['prefix']}'."
    fi
    koopa_alert "Converting SAM files in '${dict['prefix']}' to BAM format."
    if [[ "${bool['keep_sam']}" -eq 1 ]]
    then
        koopa_alert_note 'SAM files will be preserved.'
    else
        koopa_alert_note 'SAM files will be deleted.'
    fi
    for sam_file in "${sam_files[@]}"
    do
        local bam_file
        bam_file="${sam_file%.sam}.bam"
        koopa_samtools_convert_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        if [[ "${bool['keep_sam']}" -eq 0 ]]
        then
            koopa_rm "$sam_file"
        fi
    done
    return 0
}
