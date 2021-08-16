#!/usr/bin/env bash

# FIXME Consider putting the index in a top-level directory.
# FIXME Consider nesting the samples a 'samples' subdirectory.
# FIXME Need to rework handoff to 'kallisto_index', using '--output-dir' instead.

koopa:::kallisto_index() { # {{{1
    # """
    # Generate kallisto index.
    # @note Updated 2021-08-16.
    # """
    local app dict index_args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'kallisto'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file "${dict[fasta_file]}"
    if [[ -d "${dict[output_dir]}" ]]
    then
        koopa::alert_note \
            "Kallisto transcriptome index exists at '${dict[output_dir]}'." \
            "Skipping on-the-fly indexing of '${dict[fasta_file]}'."
        return 0
    fi
    koopa::h2 "Generating kallisto index at '${dict[output_dir]}'."
    koopa::mkdir "${dict[output_dir]}"
    dict[index_file]="${dict[output_dir]}/kallisto.idx"
    dict[log_file]="${dict[output_dir]}/index.log"
    index_args=(
        "--index=${dict[index_file]}"
        '--kmer-size=31'
        '--make-unique'
        "${dict[fasta_file]}"
    )
    koopa::dl 'Index args' "${index_args[*]}"
    kallisto index "${index_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}



# FIXME Work on adding support for genomebam here.
# FIXME AcidGenomes downloader needs to generate this chromosomes.txt file.

# To visualize the pseudoalignments we need to run kallisto with the
# --genomebam option. To do this we need two additional files, a GTF file, which
# describes where the transcripts lie in the genome, and a text file containing
# the length of each chromosome. These files are part of the test directory.
# To run kallisto we type:

#     kallisto quant \
#         -i transcripts.kidx \
#         -b 30 -o kallisto_out \
#         --genomebam \
#         --gtf transcripts.gtf.gz \
#         --chromosomes chrom.txt \
#         reads_1.fastq.gz \
#         reads_2.fastq.gz

# this is the same run as above, but now we supply --gtf transcripts.gtf.gz for
# the GTF file and the chromosome file --chromosomes chrom.txt. For a larger
# transcriptome we recommend downloading the GTF file from the same release and
# data source as the FASTA file used to construct the index. The output now
# contains two additional files pseudoalignments.bam and
# pseudoalignments.bam.bai. The files can be viewed and processed using Samtools
# or a genome browser such as IGV.



# FIXME Simplify the FASTA/index handling here.
# FIXME Need to require the genomebam settings here...GTF input.
koopa:::kallisto_quant_paired_end() { # {{{1
    # """
    # Run kallisto quant (per paired-end sample).
    # @note Updated 2021-08-16.
    #
    # Important options:
    # * --bias: Learns parameters for a model of sequences specific bias and
    #   corrects the abundances accordlingly.
    # * --fr-stranded: Run kallisto in strand specific mode, only fragments
    #   where the first read in the pair pseudoaligns to the forward strand of a
    #   transcript are processed. If a fragment pseudoaligns to multiple
    #   transcripts, only the transcripts that are consistent with the first
    #   read are kept.
    # * --rf-stranded: Same as '--fr-stranded', but the first read maps to the
    #   reverse strand of a transcript.

    # @seealso
    # - https://pachterlab.github.io/kallisto/manual
    # - https://littlebitofdata.com/en/2017/08/strandness_in_rnaseq/
    # - https://salmon.readthedocs.io/en/latest/library_type.html
    # """
    local app dict quant_args
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'kallisto'
    declare -A app=(
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [threads]="$(koopa::cpu_count)"
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                dict[bootstraps]="${1#*=}"
                shift 1
                ;;
            --chromosomes-file=*)
                # FIXME Need to define this in main function.
                dict[chromosomes_file]="${1#*=}"
                shift 1
                ;;
            --fastq-r1=*)
                dict[fastq_r1]="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                dict[fastq_r2]="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                # FIXME Need to define this in main function.
                dict[gff_file]="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                dict[index_file]="${1#*=}"
                shift 1
                ;;
            --lib-type=*)
                dict[lib_type]="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                dict[r1_tail]="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                dict[r2_tail]="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_file \
        "${dict[fastq_r1]}" \
        "${dict[fastq_r2]}" \
        "${dict[gff_file]}" \
        "${dict[index_file]}"
    dict[fastq_r1_bn]="$(koopa::basename "${dict[fastq_r1]}")"
    dict[fastq_r1_bn]="${dict[fastq_r1_bn]/${dict[r1_tail]}/}"
    dict[fastq_r2_bn]="$(koopa::basename "${dict[fastq_r2]}")"
    dict[fastq_r2_bn]="${dict[fastq_r2_bn]/${dict[r2_tail]}/}"
    koopa::assert_are_identical "${dict[fastq_r1_bn]}" "${dict[fastq_r2_bn]}"
    dict[id]="${dict[fastq_r1_bn]}"
    dict[sample_output_dir]="${dict[output_dir]}/${dict[id]}"
    if [[ -d "${dict[sample_output_dir]}" ]]
    then
        koopa::alert_note "Skipping '${dict[id]}'."
        return 0
    fi
    koopa::h2 "Quantifying '${dict[id]}' into '${dict[sample_output_dir]}'."
    koopa::mkdir "${dict[sample_output_dir]}"
    dict[log_file]="${dict[sample_output_dir]}/quant.log"
    quant_args=(
        '--bias'
        "--bootstrap-samples=${dict[bootstraps]}"
        "--chromosomes=${dict[chromosomes_file]}"
        '--genomebam'
        "--gtf=${dict[gff_file]}"
        "--index=${dict[index_file]}"
        "--output-dir=${dict[sample_output_dir]}"
        '--pseudobam'
        "--threads=${dict[threads]}"
        '--verbose'
    )
    # Run kallisto in stranded mode, depending on the library type. Using salmon
    # library type codes here, for consistency. Doesn't currently support an
    # auto detection mode, like salmon. Most current libraries are 'ISR' /
    # '--rf-stranded', if unsure.
    case "${dict[lib_type]}" in
        A)
            ;;
        ISF)
            quant_args+=('--fr-stranded')
            ;;
        ISR)
            quant_args+=('--rf-stranded')
            ;;
        *)
            koopa::invalid_arg "${dict[lib_type]}"
            ;;
    esac
    quant_args+=("${dict[fastq_r1]}" "${dict[fastq_r2]}")
    koopa::dl 'Quant args' "${quant_args[*]}"
    kallisto quant "${quant_args[@]}" 2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}

# FIXME Simplify the FASTA/index handling here.
koopa:::kallisto_quant_single_end() { # {{{1
    # Run kallisto quant (per single-end sample).
    # @note Updated 2021-08-16.
    #
    # Must supply the length and standard deviation of the fragment length
    # (not the read length).
    #
    # Fragment length refers to the length of the fragments loaded onto the
    # sequencer. If this is your own dataset, then either you or whoever did the
    # sequencing should know this (it can be estimated from a bioanalyzer plot).
    # If this is a public dataset, then hopefully the value is written down
    # somewhere.
    #
    # Typical values for RNA-seq are '--fragment-length=200' and '--sd=30'.
    #
    # @seealso
    # - https://www.biostars.org/p/252823/
    # """
    # FIXME We need to calculate the standard deviation here...
    # FIXME Don't use '--bias' flag here.
    # FIXME Pass in the '--single' flag.
    # FIXME Pass in the '--verbose' flag here.
    echo 'FIXME'

    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            --fragment-length=*)
                fragment_length="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                index_file="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            # FIXME What's the tail name to use here?
            --r1-tail=*)
                r1_tail="${1#*=}"
                shift 1
                ;;
            --sd=*)
                sd="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set \
        'fragment_length' \
        'sd'

    # FIXME need these flags:
    # Typical values for RNA-seq are '--fragment-length=200' and '--sd=30'.

}

# FIXME This needs to pass-in GTF and chromosome.txt file.
koopa::run_kallisto_paired_end() { # {{{1
    # """
    # Run kallisto on multiple samples.
    # @note Updated 2021-08-16.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # """
    local app dict
    local fastq_r1_files fastq_r1 fastq_r2 str
    koopa::assert_has_args "$#"
    declare -A app=(
        [find]="$(koopa::locate_find)"
        [sort]="$(koopa::locate_sort)"
    )
    declare -A dict=(
        [bootstraps]=30
        [fastq_dir]='fastq'
        [lib_type]='A'
        [output_dir]='kallisto'
        [r1_tail]='_R1_001.fastq.gz'
        [r2_tail]='_R2_001.fastq.gz'
    )
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --chromosomes-file=*)
                chromosomes_file="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            --gff-file=*)
                gff_file="${1#*=}"
                shift 1
                ;;
            --lib-type=*)
                lib_type="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::h1 'Running kallisto.'
    koopa::activate_conda_env 'kallisto'
    dict[chromosomes_file]="$(koopa::realpath "${dict[chromosomes_file]}")"
    dict[fasta_file]="$(koopa::realpath "${dict[fasta_file]}")"
    dict[fastq_dir]="$(koopa::realpath "${dict[fastq_dir]}")"
    dict[gff_file]="$(koopa::realpath "${dict[gff_file]}")"
    koopa::mkdir "${dict[output_dir]}"
    dict[output_dir]="$(koopa::realpath "${dict[output_dir]}")"
    dict[index_dir]="${dict[output_dir]}/index"
    dict[index_file]="${dict[index_dir]}/kallisto.idx"
    dict[samples_dir]="${dict[output_dir]}/samples"
    koopa::dl \
        'Bootstraps' "${dict[bootstraps]}" \
        'Chromosomes file' "${dict[chromosomes_file]}" \
        'FASTA file' "${dict[fasta_file]}" \
        'FASTQ dir' "${dict[fastq_dir]}" \
        'GFF file' "${dict[gff_file]}" \
        'Output dir' "${dict[output_dir]}" \
        'R1 tail' "${dict[r1_tail]}" \
        'R2 tail' "${dict[r2_tail]}"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_r1_files <<< "$( \
        "${app[find]}" "$fastq_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type 'f' \
            -name "*${r1_tail}" \
            -not -name '._*' \
            -print \
        | "${app[sort]}" \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQ files in '${dict[fastq_dir]}' ending \
with '${dict[r1_tail]}'."
    fi
    str="$(koopa::ngettext "${#fastq_r1_files[@]}" 'sample' 'samples')"
    koopa::alert_info "${#fastq_r1_files[@]} ${str} detected."
    # Index {{{2
    # --------------------------------------------------------------------------
    koopa:::kallisto_index \
        --fasta-file="${dict[fasta_file]}" \
        --output-dir="$index_dir"
    koopa::assert_is_file "${dict[index_file]}"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${dict[r1_tail]}/${dict[r2_tail]}}"
        koopa:::kallisto_quant \
            --bootstraps="${dict[bootstraps]}" \
            --chromosomes-file="${dict[chromosomes_file]}" \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --gff-file="${dict[gff_file]}" \
            --index-file="${dict[index_file]}" \
            --lib-type="${dict[lib_type]}" \
            --output-dir="${dict[output_dir]}" \
            --r1-tail="${dict[r1_tail]}" \
            --r2-tail="${dict[r2_tail]}"
    done
    koopa::alert_success 'kallisto run completed successfully.'
    return 0
}

# FIXME This needs to support GTF file and 'chromosomes.txt' file.
# FIXME Rework, using conventions defined in paired-end runners.
koopa::run_kallisto_single_end() { # {{{1
    # """
    # Run kallisto on multiple single-end FASTQ files.
    # @note Updated 2021-08-16.
    # """
    local bootstraps fastq_dir fragment_length output_dir sd tail
    koopa::assert_has_args "$#"
    bootstraps=30
    fastq_dir='fastq'
    fragment_length=200
    output_dir='kallisto'
    sd=30
    tail='.fastq.gz'
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
                shift 1
                ;;
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --fastq-dir=*)
                fastq_dir="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                index_dir="${1#*=}"
                echo "$index_dir"  # FIXME
                shift 1
                ;;
            --output-dir=*)
                output_dir="${1#*=}"
                shift 1
                ;;
            --tail=*)
                tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done


    # FIXME Need to handle the sample indexing...

    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify with kallisto.
    fastq_files=()  # FIXME
    for fastq in "${fastq_files[@]}"
    do
        echo "$fastq"  # FIXME
        koopa::kalisto_quant_single_end \
            --fragment-length="$fragment_length" \
            --sd="$sd" \
            --tail="$tail"
    done
    koopa::alert_success 'kallisto run completed successfully.'
}
