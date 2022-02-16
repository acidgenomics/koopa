#!/usr/bin/env bash

# FIXME Need to harden and test all of these functions.

# FIXME Rework this using a dict approach.
# FIXME Rename this to 'koopa::filter_bam'?
# FIXME This also calls sambamba, so we need to improve the name here.

koopa::bam_filter() { # {{{1
    # """
    # Apply multi-step filtering to BAM files.
    # @note Updated 2021-10-26.
    # """
    local bam_file bam_files dir final_output_bam final_output_tail input_bam
    local input_tail output_bam output_tail
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    readarray -t bam_files <<< "$( \
        koopa::find \
            --glob='*.sorted.bam' \
            --max-depth 3 \
            --min-depth 1 \
            --prefix="$dir" \
            --sort \
            --type='f' \
    )"
    if ! koopa::is_array_non_empty "${bam_files[@]:-}"
    then
        koopa::stop "No BAM files detected in '${dir}'."
    fi
    koopa::h1 "Filtering BAM files in '${dir}'."
    koopa::activate_conda_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        final_output_tail='filtered'
        final_output_bam="${bam_file%.bam}.${final_output_tail}.bam"
        if [[ -f "$final_output_bam" ]]
        then
            koopa::alert_note "Skipping '${final_output_bam}'."
            continue
        fi
        # 1. Filter duplicate reads.
        input_bam="$bam_file"
        output_tail='filtered-1-no-duplicates'
        output_bam="${input_bam%.bam}.${output_tail}.bam"
        koopa::sambamba_filter_duplicates \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # 2. Filter unmapped reads.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-2-no-unmapped'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa::sambamba_filter_unmapped \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # 3. Filter multimapping reads. Note that this step can overfilter some
        # samples with with large global changes in chromatin state.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-3-no-multimappers'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa::sambamba_filter_multimappers \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        koopa::cp "$output_bam" "$final_output_bam"
        koopa::sambamba_index "$final_output_bam"
    done
    # FIXME Rework this, not requiring conda activation.
    koopa::deactivate_conda
    return 0
}

koopa::bam_sort() { # {{{1
    # """
    # Sort multiple BAM files in a directory.
    # @note Updated 2020-08-13.
    # """
    local bam_file bam_files dir
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    # FIXME Rework using 'koopa::find'.
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.bam' \
            -not -iname '*.filtered.*' \
            -not -iname '*.sorted.*' \
            -print \
        | sort \
    )"
    if ! koopa::is_array_non_empty "${bam_files[@]:-}"
    then
        koopa::stop "No BAM files detected in '${dir}'."
    fi
    koopa::h1 "Sorting BAM files in '${dir}'."
    koopa::activate_conda_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        koopa::sambamba_sort "$bam_file"
    done
    koopa::deactivate_conda
    return 0
}

koopa::convert_sam_to_bam() { # {{{1
    # """
    # Convert multiple SAM files in a directory to BAM files.
    # @note Updated 2021-09-20.
    # """
    local bam_file keep_sam pos sam_file sam_files
    keep_sam=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--keep-sam')
                keep_sam=1
                shift 1
                ;;
            '-'*)
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
    # FIXME Rework using 'koopa::find'.
    readarray -t sam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sam' \
            -print \
        | sort \
    )"
    if ! koopa::is_array_non_empty "${sam_files[@]:-}"
    then
        koopa::stop "No SAM files detected in '${dir}'."
    fi
    koopa::h1 "Converting SAM files in '${dir}' to BAM format."
    koopa::activate_conda_env 'samtools'
    case "$keep_sam" in
        '0')
            koopa::alert_note 'SAM files will be deleted.'
            ;;
        '1')
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
    # FIXME Don't do this approach here, rework.
    koopa::deactivate_conda
    return 0
}
