#!/usr/bin/env bash

koopa::convert_sam_to_bam() { # {{{1
    # """
    # Convert multiple SAM files in a directory to BAM files.
    # @note Updated 2020-08-13.
    # """
    local bam_file keep_sam pos sam_file sam_files
    keep_sam=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --keep-sam)
                keep_sam=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    readarray -t sam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sam' \
            -print \
        | sort \
    )"
    if ! koopa::is_array_non_empty "${sam_files[@]}"
    then
        koopa::stop "No SAM files detected in '${dir}'."
    fi
    koopa::h1 "Converting SAM files in '${dir}' to BAM format."
    koopa::activate_conda_env samtools
    case "$keep_sam" in
        0)
            koopa::alert_note 'SAM files will be deleted.'
            ;;
        1)
            koopa::alert_note 'SAM files will be preserved.'
            ;;
    esac
    for sam_file in "${sam_files[@]}"
    do
        bam_file="${sam_file%.sam}.bam"
        koopa::samtools_convert_sam_to_bam \
            --input-sam="$sam_file" \
            --output-bam="$bam_file"
        [[ "$keep_sam" -eq 0 ]] && koopa::rm "$sam_file"
    done
    return 0
}
