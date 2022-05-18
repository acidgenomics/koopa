#!/usr/bin/env bash

# FIXME Need to harden and test all of these functions.
# FIXME Rework this using a dict approach.
# FIXME Rename this to 'koopa_filter_bam'?
# FIXME This also calls sambamba, so we need to improve the name here.

koopa_bam_filter() {
    # """
    # Apply multi-step filtering to BAM files.
    # @note Updated 2021-10-26.
    # """
    local bam_file bam_files dir final_output_bam final_output_tail input_bam
    local input_tail output_bam output_tail
    koopa_assert_has_args_le "$#" 1
    dir="${1:-.}"
    koopa_assert_is_dir "$dir"
    dir="$(koopa_realpath "$dir")"
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern='*.sorted.bam' \
            --prefix="$dir" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dir}'."
    fi
    koopa_h1 "Filtering BAM files in '${dir}'."
    # FIXME Just locate this directly.
    koopa_conda_activate_env 'sambamba'
    for bam_file in "${bam_files[@]}"
    do
        final_output_tail='filtered'
        final_output_bam="${bam_file%.bam}.${final_output_tail}.bam"
        if [[ -f "$final_output_bam" ]]
        then
            koopa_alert_note "Skipping '${final_output_bam}'."
            continue
        fi
        # 1. Filter duplicate reads.
        input_bam="$bam_file"
        output_tail='filtered-1-no-duplicates'
        output_bam="${input_bam%.bam}.${output_tail}.bam"
        koopa_sambamba_filter_duplicates \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # 2. Filter unmapped reads.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-2-no-unmapped'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa_sambamba_filter_unmapped \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        # 3. Filter multimapping reads. Note that this step can overfilter some
        # samples with with large global changes in chromatin state.
        input_tail="$output_tail"
        input_bam="$output_bam"
        output_tail='filtered-3-no-multimappers'
        output_bam="${input_bam/${input_tail}/${output_tail}}"
        koopa_sambamba_filter_multimappers \
            --input-bam="$input_bam" \
            --output-bam="$output_bam"
        koopa_cp "$output_bam" "$final_output_bam"
        koopa_sambamba_index "$final_output_bam"
    done
    # FIXME Rework this, not requiring conda activation.
    koopa_conda_deactivate
    return 0
}
