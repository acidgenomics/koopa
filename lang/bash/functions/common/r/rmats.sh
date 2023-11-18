#!/usr/bin/env bash

koopa_rmats() {
    # """
    # Run rMATS analysis on unpaired samples.
    # @note Updated 2023-11-17.
    #
    # @seealso
    # - https://rnaseq-mats.sourceforge.io/
    # - https://nf-co.re/rnasplice/
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/rmats_prep.nf
    # - https://github.com/nf-core/rnasplice/blob/master/modules/
    #     local/rmats_post.nf
    #
    # @examples
    # # STAR GENCODE-aligned BAM files.
    # # b1_file:
    # #   control-1.bam,control-2.bam,control-3.bam
    # # b2_file:
    # #   treatment-1.bam,treatment-2.bam,treatment-3.bam
    # koopa_rmats \
    #     --b1-file='b1.txt' \
    #     --b2-file='b2.txt' \
    #     --genome-fasta-file='GRCh38.primary_assembly.genome.fa.gz' \
    #     --gtf-file='gencode.v44.annotation.gtf.gz' \
    #     --output-dir='rmats/star-gencode/treatment-vs-control'
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
    # e.g. 'GRCh38.primary_assembly.genome.fa.gz'.
    dict['genome_fasta_file']=''
    # e.g. 'gencode.v44.annotation.gtf.gz'.
    dict['gtf_file']=''
    # Using salmon library type conventions here.
    dict['lib_type']='A'
    dict['nthread']="$(koopa_cpu_count)"
    # e.g. 'rmats/star-gencode/treatment-vs-control'.
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
            '--genome-fasta-file='*)
                dict['genome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--genome-fasta-file')
                dict['genome_fasta_file']="${2:?}"
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
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
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
            '--lib-type='*)
                dict['lib_type']="${1#*=}"
                shift 1
                ;;
            '--lib-type')
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
        '--genome-fasta-file' "${dict['genome_fasta_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}"
    koopa_assert_is_file \
        "${dict['b1_file']}" \
        "${dict['b2_file']}" \
        "${dict['genome_fasta_file']}" \
        "${dict['gtf_file']}"
    dict['b1_file']="$(koopa_realpath "${dict['b1_file']}")"
    dict['b2_file']="$(koopa_realpath "${dict['b2_file']}")"
    dict['genome_fasta_file']="$(koopa_realpath "${dict['genome_fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    koopa_assert_is_not_dir "${dict['output_dir']}"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    dict['log_file']="${dict['output_dir']}/rmats.log"
    koopa_alert "Running rMATS analysis in '${dict['output_dir']}'."
    readarray -t -d ',' b1_files < "${dict['b1_file']}"
    readarray -t -d ',' b2_files < "${dict['b2_file']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b1_files[0]}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${b2_files[0]}"
    if [[ "${dict['lib_type']}" == 'A' ]]
    then
        koopa_alert 'Detecting BAM library type with salmon.'
        dict['lib_type']="$( \
            koopa_salmon_detect_bam_library_type \
                --bam-file="${b1_files[0]}" \
                --fasta-file="${dict['genome_fasta_file']}" \
        )"
    fi
    dict['lib_type']="$( \
        koopa_salmon_library_type_to_rmats "${dict['lib_type']}" \
    )"
    if [[ -z "${dict['read_length']}" ]]
    then
        koopa_alert 'Detecting BAM read length.'
        dict['read_length']="$(koopa_bam_read_length "${b1_files[0]}")"
    fi
    if [[ -z "${dict['read_type']}" ]]
    then
        koopa_alert 'Detecting BAM read type.'
        dict['read_type']="$(koopa_bam_read_type "${b1_files[0]}")"
    fi
    case "${dict['read_type']}" in
        'paired' | 'single')
            ;;
        *)
            koopa_stop "Unsupported read type: '${dict['read_type']}'."
            ;;
    esac
    if koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file_in_wd --ext='gtf')"
        koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    koopa_cp "${dict['b1_file']}" "${dict['output_dir']}/b1.txt"
    koopa_cp "${dict['b2_file']}" "${dict['output_dir']}/b2.txt"
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
    koopa_print "${app['rmats']} ${rmats_args[*]}" \
        >> "${dict['log_file']}"
    export PYTHONUNBUFFERED=1
    "${app['rmats']}" "${rmats_args[@]}" \
        |& "${app['tee']}" -a "${dict['log_file']}"
    unset -v PYTHONUNBUFFERED
    koopa_rm "${dict['tmp_dir']}"
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gtf_file']}"
    fi
    return 0
}
