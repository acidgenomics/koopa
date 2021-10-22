#!/usr/bin/env bash

# NOTE Need to migrate these functions to r-koopa.

koopa::bam_filter() { # {{{1
    # """
    # Apply multi-step filtering to BAM files.
    # @note Updated 2021-08-17.
    # """
    local bam_file bam_files dir final_output_bam final_output_tail input_bam
    local input_tail output_bam output_tail
    koopa::assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    readarray -t bam_files <<< "$( \
        find "$dir" \
            -maxdepth 3 \
            -mindepth 1 \
            -type f \
            -iname '*.sorted.bam' \
            -print \
        | sort \
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
            koopa::alert_note "Skipping '$(basename "$final_output_bam")'."
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
    koopa::deactivate_conda
    return 0
}
