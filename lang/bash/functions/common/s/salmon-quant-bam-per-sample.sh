#!/usr/bin/env bash

# FIXME Don't attempt to define the output directory by the sample name here.

# NOTE Attempting to pass '--gencode' flag here currently doesn't work correctly
# when processing GENCODE-aligned Nanopore guppy > minimap2 > BAM output.

koopa_salmon_quant_bam_per_sample() {
    # """
    # Run salmon quant on a single BAM file.
    # @note Updated 2023-10-20.
    #
    # @seealso
    # - salmon quant --help-alignment
    # - https://salmon.readthedocs.io/en/latest/salmon.html
    #
    # @examples
    # > koopa_salmon_quant_bam_per_sample \
    # >     --bam-file='bam/sample1.bam' \
    # >     --output-dir='salmon/sample1' \
    # >     --transcriptome-fasta-file='transcriptome.fa.gz'
    # """
    local -A app dict
    local -a quant_args
    koopa_assert_has_args "$#"
    app['salmon']="$(koopa_locate_salmon)"
    koopa_assert_is_executable "${app[@]}"
    # e.g. 'sample1.bam'.
    dict['bam_file']=''
    # Current recommendation in bcbio-nextgen.
    dict['bootstraps']=30
    # > dict['gencode']=0
    # Detect library fragment type (strandedness) automatically.
    dict['lib_type']='A'
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=14
    # e.g. 'salmon'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    # e.g. 'gencode.v39.transcripts.fa.gz'.
    dict['transcriptome_fasta_file']=''
    quant_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bam-file='*)
                dict['bam_file']="${1#*=}"
                shift 1
                ;;
            '--bam-file')
                dict['bam_file']="${2:?}"
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
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--transcriptome-fasta-file='*)
                dict['transcriptome_fasta_file']="${1#*=}"
                shift 1
                ;;
            '--transcriptome-fasta-file')
                dict['transcriptome_fasta_file']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            # > '--gencode')
            # >     dict['gencode']=1
            # >     shift 1
            # >     ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--bam-file' "${dict['bam_file']}" \
        '--lib-type' "${dict['lib_type']}" \
        '--output-dir' "${dict['output_dir']}" \
        '--transcriptome-fasta-file' "${dict['transcriptome_fasta_file']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "salmon quant requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    koopa_assert_is_file \
        "${dict['bam_file']}" \
        "${dict['transcriptome_fasta_file']}"
    dict['transcriptome_fasta_file']="$( \
        koopa_realpath "${dict['transcriptome_fasta_file']}" \
    )"
    dict['id']="$(koopa_basename_sans_ext "${dict['bam_file']}")"
    dict['bam_file']="$(koopa_realpath "${dict['bam_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['id']}' in '${dict['output_dir']}'."
    quant_args+=(
        "--alignments=${dict['bam_file']}"
        "--libType=${dict['lib_type']}"
        '--no-version-check'
        "--numBootstraps=${dict['bootstraps']}"
        "--output=${dict['output_dir']}"
        "--targets=${dict['transcriptome_fasta_file']}"
        "--threads=${dict['threads']}"
    )
    koopa_dl 'Quant args' "${quant_args[*]}"
    "${app['salmon']}" quant "${quant_args[@]}"
    return 0
}
