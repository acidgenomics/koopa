#!/usr/bin/env bash

# FIXME Rework this locating samtools directly instead of activating conda env.

koopa_convert_sam_to_bam() {
    # """
    # Convert multiple SAM files in a directory to BAM files.
    # @note Updated 2023-04-05.
    # """
    local -A dict
    local -a pos sam_files
    local sam_file
    dict['keep_sam']=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep-sam')
                dict['keep_sam']=1
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
    dict['dir']="${1:-${PWD:?}}"
    koopa_assert_is_dir "$dir"
    dict['dir']="$(koopa_realpath "${dict['dir']}")"
    # FIXME Rework using 'koopa_find'.
    readarray -t sam_files <<< "$( \
        find "${dict['dir']}" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sam' \
            -print \
        | sort \
    )"
    if ! koopa_is_array_non_empty "${sam_files[@]:-}"
    then
        koopa_stop "No SAM files detected in '${dict['dir']}'."
    fi
    koopa_h1 "Converting SAM files in '${dict['dir']}' to BAM format."
    # FIXME Just locate this directly.
    koopa_conda_activate_env 'samtools'
    case "${dict['keep_sam']}" in
        '0')
            koopa_alert_note 'SAM files will be deleted.'
            ;;
        '1')
            koopa_alert_note 'SAM files will be preserved.'
            ;;
    esac
    for sam_file in "${sam_files[@]}"
    do
        local bam_file
        bam_file="${sam_file%.sam}.bam"
        koopa_samtools_convert_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        if [[ "${dict['keep_sam']}" -eq 0 ]]
        then
            koopa_rm "$sam_file"
        fi
    done
    # FIXME Don't do this approach here, rework.
    koopa_conda_deactivate
    return 0
}
