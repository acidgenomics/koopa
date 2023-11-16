#!/usr/bin/env bash

koopa_rmats() {
    # """
    # Run rMATS analysis on unpaired samples.
    # @note Updated 2023-11-16.
    # """
    local -A app bool dict
    local -a b1_files b2_files rmats_args
    app['rmats']="$(koopa_locate_rmats)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_gtf_file']=0
    # e.g. 'b1.txt': control samples.
    dict['b1_file']=''
    # e.g. 'b2.txt': treated samples.
    dict['b2_file']=''
    dict['cstat']=0.0001
    # e.g. 'gencode.v44.annotation.gtf.gz'.
    dict['gtf_file']=''
    # e.g. 'fr-unstranded'.
    dict['lib_type']=''
    dict['nthread']="$(koopa_cpu_count)"
    # e.g. 'star-gencode'.
    dict['output_dir']=''
    # e.g. '150'.
    dict['read_length']=''
    # e.g. 'paired'.
    dict['read_type']=''
    dict['tmp_dir']="$(koopa_tmp_dir_in_wd)"
    while (("$#"))
    do
        case "$1" in
            # Required key-value pairs -----------------------------------------
            '--b1-file='*)
                dict['b1_file']="${1#*=}"
                shift 1
                ;;
            '--b1-file')
                dict['b1_file']="${2:?}"
                shift 2
                ;;
            '--b2-file='*)
                dict['b2_file']="${1#*=}"
                shift 1
                ;;
            '--b2-file')
                dict['b2_file']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--output-directory='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-directory')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            # Optional key-value pairs -----------------------------------------
            '--alpha-threshold='*)
                dict['cstat']="${1#*=}"
                shift 1
                ;;
            '--alpha-threshold')
                dict['cstat']="${2:?}"
                shift 2
                ;;
            '--library-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--library-type')
                dict['lib_type']="${2:?}"
                shift 2
                ;;
            '--read-length='*)
                dict['read_length']="${1#*=}"
                shift 1
                ;;
            '--read-length')
                dict['read_length']="${2:?}"
                shift 2
                ;;
            '--read-type='*)
                dict['read_type']="${1#*=}"
                shift 1
                ;;
            '--read-type')
                dict['read_type']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--alpha-threshold' "${dict['cstat']}" \
        '--b1-file' "${dict['b1_file']}" \
        '--b2-file' "${dict['b2_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--output-directory' "${dict['output_dir']}"
    koopa_assert_is_file \
        "${dict['b1_file']}" \
        "${dict['b2_file']}" \
        "${dict['gtf_file']}"
    koopa_assert_is_not_dir "${dict['output_dir']}"
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
    readarray -t -d ',' b1_files < "${dict['b1_file']}"
    readarray -t -d ',' b2_files < "${dict['b2_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b1_files[0]}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b2_files[0]}"
    if [[ -z "${dict['lib_type']}" ]]
    then
        koopa_stop 'FIXME lib_type'
        # FIXME Need to remap salmon code to rMATS convention.
        # FIXME Need to add a function to take salmon library type and convert it
        # to rMATS convention (e.g. 'fr-unstranded').
    fi
    if [[ -z "${dict['read_length']}" ]]
    then
        koopa_stop 'FIXME read_length'
    fi
    if [[ -z "${dict['read_type']}" ]]
    then
        koopa_stop 'FIXME read_type'
    fi
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
        '--tmp' "${dict['tmp_dir']}"
        '--tstat' "${dict['nthread']}"
    )
    koopa_dl 'rmats' "${rmats_args[*]}"
    "${app['tee']}" \
        >("${app['rmats']}" "${rmats_args[@]}") \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    koopa_cp \
        --target-directory="${dict['output_dir']}" \
        "${dict['b1_file']}" \
        "${dict['b2_file']}"
    koopa_rm "${dict['tmp_dir']}"
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gtf_file']}"
    fi
    return 0
}
