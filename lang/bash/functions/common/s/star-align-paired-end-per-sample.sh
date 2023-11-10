#!/usr/bin/env bash

koopa_star_align_paired_end_per_sample() {
    # """
    # Run STAR aligner on a paired-end sample.
    # @note Updated 2023-11-10.
    #
    # @section On-the-fly splice junction database generation:
    #
    # STAR can now generate a splice junction database per sample on the fly.
    # This is preferable, since we can tailor it for projects containing
    # samples with variable read lengths. Refer to STAR manual "3.3.1 Using
    # annotations at the mapping stage" and "5.5 Splice junctions" for
    # additional details.
    #
    # Ensure genome-level BAM file is indexed for IGV. Can skip indexing of
    # transcriptome-level 'Aligned.toTranscriptome.out.bam' file.
    #
    # @section ENCODE options (STAR manual 3.3.2):
    #
    # * --outFilterType BySJout:
    #   Reduces the number of spurious junctions.
    # * --outFilterMultimapNmax 20:
    #   Max number of multiple alignments allowed for a read. If exceeded, the
    #   read is considered unmapped.
    # * --alignSJoverhangMin 8:
    #   Minimum overhang for unannotated junctions.
    # * --alignSJDBoverhangMin 1:
    #   Minimum overhang for annotated junctions.
    # * --outFilterMismatchNmax 999:
    #   Maximum number of mismatches per pair. Large number switches off this
    #   filter.
    # * --outFilterMismatchNoverReadLmax 0.04:
    #   Max number of mismatches per pair relative to read length: for 2x100b,
    #   max number of mis-matches is 0.04*200=8 for the paired read.
    # * --alignIntronMin 20:
    #   Minimum intron length.
    # * --alignIntronMax 1000000:
    #   Maximum intron length.
    # * --alignMatesGapMax 1000000:
    #   Maximum genomic distance between mates.
    #
    # @section Transcriptome BAM output (STAR manual 7):
    #
    # With '--quantMode TranscriptomeSAM' option STAR will output alignments
    # translated into transcript coordinates in the
    # 'Aligned.toTranscriptome.out.bam' file (in addition to alignments in
    # genomic coordinates in 'Aligned.*.sam/bam' files). These transcriptomic
    # alignments can be used with various transcript quantification software
    # that require reads to be mapped to transcriptome, such as RSEM.
    #
    # @section Other potentially useful settings:
    #
    # * --limitOutSJcollapsed 2000000:
    #   Used by bcbio. Default is 1000000.
    # * --outSAMattributes NH HI AS NM MD:
    #   Used by nf-core rnaseq.
    # * --outSAMmapqUnique 60:
    #   Used by bcbio. The mapping quality MAPQ (column 5) is 255 for uniquely
    #   mapping reads, and 'int(-10*log10(1-1/Nmap))' for multi-mapping reads.
    #   This scheme is same as the one used by TopHat and is compatible with
    #   Cufflinks. The default MAPQ=255 for the unique mappers maybe changed
    #   with '--outSAMmapqUnique' parameter (integer 0 to 255) to ensure
    #   compatibility with downstream tools such as GATK.
    # * --outSAMstrandField intronMotif:
    #   Used by bcbio and nf-core rnaseq. For unstranded RNA-seq data,
    #   Cufflinks/Cuffdiff require spliced alignments with XS strand attribute,
    #   which STAR will generate with '--outSAMstrandField intronMotif' option.
    #   As required, the XS strand attribute will be generated for all
    #   alignments that contain splice junctions. The spliced alignments that
    #   have undefined strand (i.e. containing only non-canonical unannotated
    #   junctions) will be suppressed.
    # * --outSAMunmapped Within:
    #   Unmapped reads can be output into the SAM/BAM 'Aligned.*' file(s) with
    #   '--outSAMunmapped Within' option. '--outSAMunmapped Within KeepPairs'
    #   will (redundantly) record unmapped mate for each alignment, and, in
    #   case of unsorted output, keep it adjacent to its mapped mate (this
    #   only affects multi-mapping reads). uT SAM tag indicates reason for not
    #   mapping.
    # * --quantTranscriptomeBan Singleend:
    #   Used by nf-core rnaseq.
    # * --sjdbInsertSave All:
    #   The on the fly genome indices can be saved for reuse with
    #   '--sjdbInsertSave All' into 'STARgenome' directory inside the current
    #   run directory.
    #
    # @seealso
    # - For on-the-fly splice junction database genration, rather than using
    #   the fixed read length during genome indexing:
    # - https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     star/align/main.nf
    # - STAR salmon alignment options:
    #   https://github.com/nf-core/rnaseq/blob/master/conf/modules.config
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     star.py
    # - https://www.biostars.org/p/243683/
    # - https://github.com/hbctraining/Intro-to-rnaseq-hpc-O2/blob/
    #     master/lessons/03_alignment.md
    # - https://github.com/leipzig/clk/
    #
    # @examples
    # > koopa_star_align_paired_end_per_sample \
    # >     --fastq-r1-file='fastq/sample1_R1_001.fastq.gz' \
    # >     --fastq-r2-file='fastq/sample1_R2_001.fastq.gz' \
    # >     --index-dir='indexes/star-gencode' \
    # >     --output-dir='quant/star-gencode/sample1'
    # """
    local -A app bool dict
    local -a align_args
    app['star']="$(koopa_locate_star --realpath)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    bool['tmp_gtf_file']=0
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. 'gencode.v39.annotation.gtf.gz'
    dict['gtf_file']=''
    # e.g. 'indexes/star-gencode'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=30
    # e.g. 'quant/star-gencode/sample1'.
    dict['output_dir']=''
    dict['threads']="$(koopa_cpu_count)"
    align_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--fastq-r1-file='*)
                dict['fastq_r1_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r1-file')
                dict['fastq_r1_file']="${2:?}"
                shift 2
                ;;
            '--fastq-r2-file='*)
                dict['fastq_r2_file']="${1#*=}"
                shift 1
                ;;
            '--fastq-r2-file')
                dict['fastq_r2_file']="${2:?}"
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
            '--index-dir='*)
                dict['index_dir']="${1#*=}"
                shift 1
                ;;
            '--index-dir')
                dict['index_dir']="${2:?}"
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
        '--fastq-r1-file' "${dict['fastq_r1_file']}" \
        '--fastq-r2-file' "${dict['fastq_r2_file']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR requires ${dict['mem_gb_cutoff']} GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    koopa_assert_is_dir "${dict['index_dir']}"
    koopa_assert_is_file \
        "${dict['fastq_r1_file']}" \
        "${dict['fastq_r2_file']}" \
        "${dict['gtf_file']}"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    dict['fastq_r1_file']="$(koopa_realpath "${dict['fastq_r1_file']}")"
    dict['fastq_r2_file']="$(koopa_realpath "${dict['fastq_r2_file']}")"
    dict['fastq_r1_bn']="$(koopa_basename "${dict['fastq_r1_file']}")"
    dict['fastq_r2_bn']="$(koopa_basename "${dict['fastq_r2_file']}")"
    dict['output_dir']="$(koopa_init_dir "${dict['output_dir']}")"
    koopa_alert "Quantifying '${dict['fastq_r1_bn']}' and \
'${dict['fastq_r2_bn']}' in '${dict['output_dir']}'."
    if koopa_is_compressed_file "${dict['fastq_r1_file']}"
    then
        bool['tmp_fastq_r1_file']=1
        dict['tmp_fastq_r1_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['fastq_r1_file']}" \
            --output-file="${dict['tmp_fastq_r1_file']}"
        dict['fastq_r1_file']="${dict['tmp_fastq_r1_file']}"
    fi
    if koopa_is_compressed_file "${dict['fastq_r2_file']}"
    then
        bool['tmp_fastq_r2_file']=1
        dict['tmp_fastq_r2_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['fastq_r2_file']}" \
            --output-file="${dict['tmp_fastq_r2_file']}"
        dict['fastq_r2_file']="${dict['tmp_fastq_r2_file']}"
    fi
    if koopa_is_compressed_file "${dict['gtf_file']}"
    then
        bool['tmp_gtf_file']=1
        dict['tmp_gtf_file']="$(koopa_tmp_file_in_wd)"
        koopa_decompress \
            --input-file="${dict['gtf_file']}" \
            --output-file="${dict['tmp_gtf_file']}"
        dict['gtf_file']="${dict['tmp_gtf_file']}"
    fi
    dict['read_length']="$(koopa_fastq_read_length "${dict['fastq_r1_file']}")"
    dict['sjdb_overhang']="$((dict['read_length'] - 1))"
    align_args+=(
        '--alignIntronMax' 1000000
        '--alignIntronMin' 20
        '--alignMatesGapMax' 1000000
        '--alignSJDBoverhangMin' 1
        '--alignSJoverhangMin' 8
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--limitOutSJcollapsed' 2000000
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outFilterMismatchNmax' 999
        '--outFilterMismatchNoverReadLmax' 0.04
        '--outFilterMultimapNmax' 20
        '--outFilterType' 'BySJout'
        '--outReadsUnmapped' 'Fastx'
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' 0
        '--runThreadN' "${dict['threads']}"
        '--sjdbGTFfile' "${dict['gtf_file']}"
        '--sjdbOverhang' "${dict['sjdb_overhang']}"
        '--twopassMode' 'Basic'
    )
    koopa_dl 'Align args' "${align_args[*]}"
    koopa_write_string \
        --file="${dict['output_dir']}/star-align-cmd.log" \
        --string="${app['star']} ${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r2_file']}"
    fi
    if [[ "${bool['tmp_gtf_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['gtf_file']}"
    fi
    koopa_rm "${dict['output_dir']}/_STAR"*
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    koopa_assert_is_file "${dict['bam_file']}"
    koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
