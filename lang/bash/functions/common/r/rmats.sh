#!/usr/bin/env bash

# FIXME Require the user to set '--b1-file', '--b2-file'
# FIXME Ensure we copy the input b1 and b2 files to the output directory.

koopa_rmats() {
    # """
    #
    local -A app bool dict
    local -a rmats_args
    app['rmats']="$(koopa_locate_rmats)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_gtf_file']=0
    dict['b1_file']=''
    dict['b2_file']=''
    dict['cstat']=0.0001
    dict['gtf_file']='genomes/homo-sapiens-grch38-gencode-44/annotation/gencode.v44.annotation.gtf.gz'
    dict['lib_type']='fr-unstranded'
    dict['nthread']="$(koopa_cpu_count)"
    dict['output_dir']='rmats/star-gencode-2/tsd1205-100nm-24hr-vs-dmso-24hr'
    dict['read_length']=150
    dict['read_type']='paired'
    dict['tmp']="$(koopa_tmp_dir_in_wd)"
    # FIXME Parse for '--b1-file'.
    # FIXME Parse for '--b2-file'.
    # FIXME Parse for '--gtf-file'.
    # FIXME Parse for '--library-type'.
    # FIXME Parse for '--output-directory'.
    # FIXME Parse for '--read-length'.
    # FIXME Parse for '--read-type'.
    koopa_assert_is_file \
        "${dict['b1_file']}" \
        "${dict['b2_file']}" \
        "${dict['gtf_file']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/rmats.log"
    if koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file_in_wd --ext='gtf')"
        koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    # FIXME Read the files into an array and then check the first file for
    # strandedness and read length.
    rmats_args+=(
        '-t' "${dict['read_type']}"
        '--b1' "${dict['b1_file']}"
        '--b2' "${dict['b2_file']}"
        '--cstat' "${dict['cstat']}"
        '--gtf' "${dict['gtf_file']}"
        '--libType' "${dict['lib_type']}"
        '--nthread' "${dict['nthread']}"
        '--od' "${dict['output_dir']}"
        '--readLength' "${dict['read_length']}"
        '--tmp' "${dict['tmp']}"
        '--tstat' "${dict['nthread']}"
    )
    # FIXME Need to rework out to use tee to provide interactive logging.
    # Should we call in a subshell here?
    # tee >(myprogram) | tee -a file.log
    "${app['rmats']}" "${rmats_args[@]}" \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    koopa_rm "${dict['tmp']}"
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gtf_file']}"
    fi
    return 0
}
