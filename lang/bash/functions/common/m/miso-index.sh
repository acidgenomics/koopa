#!/usr/bin/env bash

koopa_miso_index() {
    # """
    # Generate a MISO index directory.
    # @note Updated 2023-11-17.
    # """
    local -A app bool dict
    koopa_activate_app_conda_env 'misopy'
    app['exon_utils']="$(koopa_locate_miso_exon_utils)"
    app['index_gff']="$(koopa_locate_miso_index_gff)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_gff_file']=0
    # e.g. 'gencode.v44.annotation.gff3.gz'.
    dict['gff_file']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=30
    # e.g. at least 500.
    dict['min_exon_size']=1000
    # e.g. 'homo-sapiens-grch38-gencode-44'.
    dict['output_dir']=''
    dict['tmp_exons_dir']="$(koopa_tmp_dir_in_wd)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--gff-file='*)
                dict['gff_file']="${1#*=}"
                shift 1
                ;;
            '--gff-file')
                dict['gff_file']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--gff-file' "${dict['gff_file']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "MISO requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file "${dict['gff_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['gff_file']="$(koopa_realpath "${dict['gff_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/index.log"
    koopa_alert "Generating MISO index at '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['gff_file']}"
    then
        bool['tmp_gff_file']=1
        dict['tmp_gff_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['gff_file']}" \
            --output-file="${dict['tmp_gff_file']}"
        dict['gff_file']="${dict['tmp_gff_file']}"
    fi
    export PYTHONUNBUFFERED=1
    "${app['index_gff']}" \
        --index \
        "${dict['gff_file']}" \
        "${dict['output_dir']}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    "${app['exon_utils']}" \
        --get-const-exons "${dict['gff_file']}" \
        --min-exon-size "${dict['min_exon_size']}" \
        --output-dir "${dict['tmp_exons_dir']}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    unset -v PYTHONUNBUFFERED
    dict['tmp_exons_gff_file']="$( \
        koopa_find \
            --hidden \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="*.min_${dict['min_exon_size']}.const_exons.gff" \
            --prefix="${dict['tmp_exons_dir']}" \
            --type='f'
    )"
    koopa_assert_is_file "${dict['tmp_exons_gff_file']}"
    koopa_mv \
        "${dict['tmp_gff_exons_file']}" \
        "${dict['output_dir']}/min_${dict['min_exon_size']}.const_exons.gff"
    koopa_rm "${dict['tmp_exons_dir']}"
    if [[ "${bool['tmp_gff_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gff_file']}"
    fi
    koopa_alert_success "MISO index created at '${dict['output_dir']}'."
    return 0
}
