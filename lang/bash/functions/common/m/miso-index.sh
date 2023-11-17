#!/usr/bin/env bash

koopa_miso_index() {
    # """
    # Generate a MISO index directory.
    # @note Updated 2023-11-17.
    # """
    local -A app dict
    koopa_activate_app_conda_env 'misopy'
    app['index_gff']="$(koopa_locate_miso_index_gff)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'gencode.v44.annotation.gff3.gz'.
    dict['gff3_file']=''
    # e.g. 'homo-sapiens-grch38-gencode-44'.
    dict['output_dir']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--gff3-file='*)
                dict['gff3_file']="${1#*=}"
                shift 1
                ;;
            '--gff3-file')
                dict['gff3_file']="${2:?}"
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
        '--gff3-file' "${dict['gff3_file']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file "${dict['gff3_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['gff3_file']="$(koopa_realpath "${dict['gff3_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/index.log"
    "${app['index_gff']}" \
        --index \
        "${dict['gff3_file']}" \
        "${dict['output_dir']}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    return 0
}
