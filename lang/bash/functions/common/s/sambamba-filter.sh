#!/usr/bin/env bash

# FIXME Consider reworking this to a per-file-centric approach instead.

koopa_sambamba_filter() {
    # """
    # Apply multi-step filtering to multiple BAM files in a directory.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     bam/__init__.py
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       chipseq/__init__.py
    # """
    local -A dict
    local -a bam_files
    local bam_file
    koopa_assert_has_args_eq "$#" 1
    dict['pattern']='*.sorted.bam'
    dict['prefix']="${1:?}"
    koopa_assert_is_dir "${dict['prefix']}"
    # We're allowing 3 levels down here to match bcbio-nextgen output.
    readarray -t bam_files <<< "$( \
        koopa_find \
            --max-depth=3 \
            --min-depth=1 \
            --pattern="${dict['pattern']}" \
            --prefix="${dict['prefix']}" \
            --sort \
            --type='f' \
    )"
    if ! koopa_is_array_non_empty "${bam_files[@]:-}"
    then
        koopa_stop "No BAM files detected in '${dict['prefix']}' matching \
pattern '${dict['pattern']}'."
    fi
    koopa_alert "Filtering BAM files in '${dict['prefix']}'."
    for bam_file in "${bam_files[@]}"
    do
        local -A dict2
        dict2['input']="$bam_file"
        dict2['bn']="$(koopa_basename_sans_ext "${dict2['input']}")"
        dict2['prefix']="$(koopa_parent_dir "${dict['input']}")"
        dict2['stem']="${dict2['prefix']}/${dict2['bn']}"
        dict2['output']="${dict2['stem']}.filtered.bam"
        # Skip processing if final output exists.
        if [[ -f "${dict2['output']}" ]]
        then
            koopa_alert_note "Skipping '${dict2['output']}'."
            continue
        fi
        dict2['file_1']="${dict2['stem']}.filtered-1-no-duplicates.bam"
        dict2['file_2']="${dict2['stem']}.filtered-2-no-unmapped.bam"
        dict2['file_3']="${dict2['stem']}.filtered-3-no-multimappers.bam"
        # 1. Filter duplicate reads.
        koopa_sambamba_filter_per_sample \
            --filter='not duplicate' \
            --input-bam="${dict2['input']}" \
            --output-bam="${dict2['file_1']}"
        # 2. Filter unmapped reads.
        koopa_sambamba_filter_per_sample \
            --filter='not unmapped' \
            --input-bam="${dict2['file_1']}" \
            --output-bam="${dict2['file_2']}"
        # 3. Filter multimapping reads. Note that this step can overfilter some
        # samples with with large global changes in chromatin state.
        koopa_sambamba_filter_per_sample \
            --filter='[XS] == null' \
            --input-bam="${dict2['file_2']}" \
            --output-bam="${dict2['file_3']}"
        koopa_cp "${dict2['file_3']}" "${dict2['output']}"
        koopa_samtools_index_bam "${dict2['output']}"
    done
    return 0
}
