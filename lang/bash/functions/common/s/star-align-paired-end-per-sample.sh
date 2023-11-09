#!/usr/bin/env bash

koopa_star_align_paired_end_per_sample() {
    # """
    # Run STAR aligner on a paired-end sample.
    # @note Updated 2023-10-20.
    #
    # Potentially useful settings:
    # * '--outSAMstrandField' 'intronMotif'
    #   For unstranded RNA-seq data, cufflinks/cuffdiff require spliced
    #   alignments with XS strand attribute, which STAR will generate with
    #   '--outSAMstrandField intronMotif' option. As required, the XS strand
    #     attribute will be generated for all alignments that contain splice
    #     junctions. The spliced alignments that have undefined strand (i.e.
    #     containing only non-canonical unannotated junctions) will be
    #     suppressed.
    #
    # @seealso
    # - For on-the-fly splice junction database genration, rather than using
    #   the fixed read length during genome indexing:
    #   STAR manual 3.3.1 Using annotations at the mapping stage.
    # - https://github.com/alexdobin/STAR/blob/master/doc/STARmanual.pdf
    # - https://github.com/nf-core/rnaseq/blob/master/modules/nf-core/
    #     star/align/main.nf
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/ngsalign/
    #     star.py
    # - https://www.biostars.org/p/243683/
    # - https://github.com/hbctraining/Intro-to-rnaseq-hpc-O2/blob/
    #     master/lessons/03_alignment.md
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
    app['star']="$(koopa_locate_star)"
    koopa_assert_is_executable "${app[@]}"
    bool['tmp_fastq_r1_file']=0
    bool['tmp_fastq_r2_file']=0
    # e.g. 'sample1_R1_001.fastq.gz'.
    dict['fastq_r1_file']=''
    # e.g. 'sample1_R2_001.fastq.gz'.
    dict['fastq_r2_file']=''
    # e.g. 'star-index'.
    dict['index_dir']=''
    dict['mem_gb']="$(koopa_mem_gb)"
    dict['mem_gb_cutoff']=60
    # e.g. 'star/sample1'.
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
        '--index-dir' "${dict['index_dir']}" \
        '--output-dir' "${dict['output_dir']}"
    if [[ -d "${dict['output_dir']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_dir']}'."
        return 0
    fi
    if [[ "${dict['mem_gb']}" -lt "${dict['mem_gb_cutoff']}" ]]
    then
        koopa_stop "STAR 'alignReads' mode requires ${dict['mem_gb_cutoff']} \
GB of RAM."
    fi
    dict['limit_bam_sort_ram']=$(( dict['mem_gb'] * 1000000000 ))
    koopa_assert_is_dir "${dict['index_dir']}"
    dict['index_dir']="$(koopa_realpath "${dict['index_dir']}")"
    koopa_assert_is_file "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
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
    align_args+=(
        '--genomeDir' "${dict['index_dir']}"
        '--limitBAMsortRAM' "${dict['limit_bam_sort_ram']}"
        '--outFileNamePrefix' "${dict['output_dir']}/"
        '--outFilterMultimapNmax' 10
        '--outSAMtype' 'BAM' 'SortedByCoordinate'
        '--quantMode' 'TranscriptomeSAM'
        '--readFilesIn' "${dict['fastq_r1_file']}" "${dict['fastq_r2_file']}"
        '--runMode' 'alignReads'
        '--runRNGseed' '0'
        '--runThreadN' "${dict['threads']}"
        '--twopassMode' 'Basic'
        #
        # FIXME Need to add these:
        # > '--sjdbGTFfile' "${dict['gtf_file']}"
        # > '--sjdbInsertSave' 'All'
        # > '--sjdbOverhang' "FIXME READ LENGTH - 1"
        #
        # ENCODE options:
        # --outFilterType BySJout
        #     reduces the number of ”spurious” junctions
        # --outFilterMultimapNmax 20
        #     max number of multiple alignments allowed for a read: if exceeded, the read is considered unmapped
        # --alignSJoverhangMin 8
        #     minimum overhang for unannotated junctions
        # --alignSJDBoverhangMin 1
        #     minimum overhang for annotated junctions
        # --outFilterMismatchNmax 999
        #     maximum number of mismatches per pair, large number switches off this filter
        # --outFilterMismatchNoverReadLmax 0.04
        #     max number of mismatches per pair relative to read length: for 2x100b, max number of mis-
        #    matches is 0.04*200=8 for the paired read
        # --alignIntronMin 20
        #    minimum intron length
        # --alignIntronMax 1000000
        #    maximum intron length
        # --alignMatesGapMax 1000000
        #    maximum genomic distance between mates
        #
        # FIXME Consider adding these for splicing analysis:
        # https://github.com/leipzig/clk/
        # > '--alignIntronMax' 1000000
        # > '--alignIntronMin' 25
        # > '--alignMatesGapMax' 1000000
        # > '--alignSJDBoverhangMin' 5
        # > '--alignSJoverhangMin' 8
        # > '--outFilterMismatchNmax' 999
        # > '--outFilterType' 'BySJout'
        #
        # bcbio settings:
        # > '--limitOutSJcollapsed' 2000000
        # > '--outReadsUnmapped' 'Fastx'
        # > '--outSAMmapqUnique' 60
        # > '--outSAMunmapped' 'Within'
        #
        # Consider setting this for unstranded:
        #
        # Need to configure splice junctions better?
        # > '--sjdbFileChrStartEnd' "${dict['sjdb_file']"
        #
        # STAR can now generate splice junction databases on the fly.
        # this is preferable since we can tailor it to the read lengths.
        #
        # Here's how to generate splice junction database on the fly:
        # rlength = fastq.estimate_maximum_read_length(fq1)
        # cmd = " --sjdbGTFfile %s " % gtf_file
        # cmd += " --sjdbOverhang %s " % str(rlength - 1)
    )
    koopa_dl 'Align args' "${align_args[*]}"
    "${app['star']}" "${align_args[@]}"
    if [[ "${bool['tmp_fastq_r1_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r1_file']}"
    fi
    if [[ "${bool['tmp_fastq_r2_file']}" -eq 1 ]]
    then
        koopa_rm "${dict['fastq_r2_file']}"
    fi
    koopa_rm "${dict['output_dir']}/_STAR"*
    # Ensure genome-level BAM file is indexed for IGV. Can skip indexing of
    # transcriptome-level 'Aligned.toTranscriptome.out.bam' file.
    dict['bam_file']="${dict['output_dir']}/Aligned.sortedByCoord.out.bam"
    koopa_assert_is_file "${dict['bam_file']}"
    koopa_alert "Indexing BAM file '${dict['bam_file']}'."
    koopa_samtools_index_bam "${dict['bam_file']}"
    return 0
}
