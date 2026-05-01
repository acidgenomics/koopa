#!/usr/bin/env bash

# FIXME Add support for pushing directly to S3, which is helpful for dealing
# with really large WGS files.

_koopa_sra_bam_dump() {
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
    app['sam_dump']="$(_koopa_locate_sam_dump)"
    app['samtools']="$(_koopa_locate_samtools)"
    _koopa_assert_is_executable "${app[@]}"
    # e.g. 'bam'.
    dict['bam_dir']=''
    # e.g. 'sra'.
    dict['prefetch_dir']=''
    dict['threads']="$(_koopa_cpu_count)"
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
                _koopa_invalid_arg "$1"
                shift 1
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--bam-directory' "${dict['bam_dir']}" \
        '--prefetch-directory' "${dict['prefetch_dir']}"
    _koopa_assert_is_ncbi_sra_toolkit_configured
    _koopa_assert_is_dir "${dict['prefetch_dir']}"
    dict['prefetch_dir']="$(_koopa_realpath "${dict['prefetch_dir']}")"
    dict['bam_dir']="$(_koopa_init_dir "${dict['bam_dir']}")"
    _koopa_alert "Dumping BAM files from '${dict['prefetch_dir']}' \
in '${dict['bam_dir']}'."
    readarray -t sra_files <<< "$(
        _koopa_find \
            --max-depth=2 \
            --min-depth=2 \
            --pattern='*.sra' \
            --prefix="${dict['prefetch_dir']}" \
            --sort \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${sra_files[@]:-}"
    for sra_file in "${sra_files[@]}"
    do
        local -A dict2
        dict2['sra_file']="$sra_file"
        dict2['id']="$(_koopa_basename_sans_ext "${dict2['sra_file']}")"
        dict2['sam_file']="${dict['bam_dir']}/${dict2['id']}.sam"
        dict2['bam_file']="${dict['bam_dir']}/${dict2['id']}.bam"
        [[ -f "${dict2['bam_file']}" ]] && continue
        _koopa_alert "Dumping SAM in '${dict2['sra_file']}' \
to '${dict2['sam_file']}."
        "${app['sam_dump']}" \
            --output-file "${dict2['sam_file']}" \
            --verbose \
            "${dict2['sra_file']}"
        _koopa_assert_is_file "${dict2['sam_file']}"
        _koopa_samtools_convert_sam_to_bam "${dict2['sam_file']}"
        _koopa_assert_is_file "${dict2['bam_file']}"
    done
    return 0
}
