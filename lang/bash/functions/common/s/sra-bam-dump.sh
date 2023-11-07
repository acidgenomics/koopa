#!/usr/bin/env bash

koopa_sra_bam_dump() {
    # """
    # Dump BAM files form SRA file list.
    # @note Updated 2023-11-07.
    #
    # @seealso
    # - sam-dump --help
    # - samtools view --help
    # - https://github.com/ncbi/sra-tools/wiki
    # - https://stackoverflow.com/questions/63290119/
    # """
    local -A app dict
    local -a sra_files
    local sra_file
    app['sam_dump']="$(koopa_locate_sam_dump)"
    app['samtools']="$(koopa_locate_samtools)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'bam'.
    dict['bam_dir']=''
    # e.g. 'sra'.
    dict['prefetch_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-directory='*)
                dict['bam_dir']="${1#*=}"
                shift 1
                ;;
            '--bam-directory')
                dict['bam_dir']="${2:?}"
                shift 2
                ;;
            '--prefetch-directory='*)
                dict['prefetch_dir']="${1#*=}"
                shift 1
                ;;
            '--prefetch-directory')
                dict['prefetch_dir']="${2:?}"
                shift 2
                ;;
            # Invalid ----------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-directory' "${dict['bam_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    koopa_assert_is_ncbi_sra_toolkit_configured
    koopa_assert_is_dir "${dict['prefetch_dir']}"
    koopa_alert "Extracting BAM from '${dict['prefetch_dir']}' \
in '${dict['bam_dir']}'."
    readarray -t sra_files <<< "$(
        koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    dict['bam_dir']="$(koopa_init_dir "${dict['bam_dir']}")"
    for sra_file in "${sra_files[@]}"
    do
        local -A dict2
        dict2['sra_file']="$sra_file"
        dict2['id']="$(koopa_basename_sans_ext "${dict2['sra_file']}")"
        dict2['sam_file']="${dict['bam_dir']}/${dict2['id']}.sam"
        dict2['bam_file']="${dict['bam_dir']}/${dict2['id']}.bam"
        [[ -f "${dict2['bam_file']}" ]] && continue
        koopa_alert "Extracting SAM in '${dict2['sra_file']}' \
to '${dict2['sam_file']}."
        "${app['sam_dump']}" \
            --output-file "${dict2['sam_file']}" \
            --verbose \
            "${dict2['sra_file']}"
        koopa_assert_is_file "${dict2['sam_file']}"
        koopa_samtools_convert_sam_to_bam "${dict2['sam_file']}"
        koopa_assert_is_file "${dict2['bam_file']}"
    done
    return 0
}
