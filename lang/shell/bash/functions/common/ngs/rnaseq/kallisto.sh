#!/usr/bin/env bash

# FIXME Put the index in a top-level directory.

# FIXME Rework, adding single-end support, similar to modifications in salmon functions.

koopa:::kallisto_index() { # {{{1
    # """
    # Generate kallisto index.
    # @note Updated 2021-08-16.
    # """
    local fasta_file index_args index_dir index_file log_file tee
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'kallisto'
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                index_file="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'fasta_file' 'index_file'
    koopa::assert_is_file "$fasta_file"
    fasta_file="$(koopa::realpath "$fasta_file")"
    if [[ -f "$index_file" ]]
    then
        index_file="$(koopa::realpath "$index_file")"
        koopa::alert_note \
            "Kallisto transcriptome index exists at '${index_file}'." \
            "Skipping on-the-fly indexing of '${fasta_file}'."
        return 0
    fi
    tee="$(koopa::locate_tee)"
    koopa::h2 "Generating kallisto index at '${index_file}'."
    index_dir="$(koopa::dirname "$index_file")"
    koopa::mkdir "$index_dir"
    log_file="${index_dir}/kallisto-index.log"
    index_dir="$(koopa::realpath "$index_dir")"
    index_args=(
        "--index=${index_file}"
        '--kmer-size=31'
        '--make-unique'
        "$fasta_file"
    )
    koopa::dl 'Index args' "${index_args[*]}"
    kallisto index "${index_args[@]}" 2>&1 | "$tee" "$log_file"
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
    local bootstraps chromosomes_file fastq_r1 fastq_r1_bn fastq_r2 fastq_r2_bn
    local id index_file lib_type log_file output_dir quant_args r1_tail r2_tail
    local sample_output_dir tee threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'kallisto'
    lib_type='A'
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
            --fastq-r1=*)
                fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                fastq_r2="${1#*=}"
                shift 1
                ;;
            --gtf-file=*)
                gtf_file="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                index_file="${1#*=}"
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
    koopa::assert_is_set 'bootstraps' 'fastq_r1' 'fastq_r2' 'gtf_file' \
        'index_file' 'lib_type' 'output_dir' 'r1_tail' 'r2_tail'
    koopa::assert_is_file "$fastq_r1" "$fastq_r2"
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"
    koopa::assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"
    id="$fastq_r1_bn"
    sample_output_dir="${output_dir}/${id}"
    if [[ -d "$sample_output_dir" ]]
    then
        koopa::alert_note "Skipping '${id}'."
        return 0
    fi
    koopa::h2 "Quantifying '${id}' into '${sample_output_dir}'."
    koopa::dl 'Bootstraps' "$bootstraps"
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    log_file="${sample_output_dir}/kallisto-quant.log"
    koopa::mkdir "$sample_output_dir"
    tee="$(koopa::locate_tee)"
    quant_args=(
        '--bias'
        "--bootstrap-samples=${bootstraps}"
        "--chromosomes=${chromosomes_file}"
        '--genomebam'
        "--gtf=${gtf_file}"
        "--index=${index_file}"
        "--output-dir=${sample_output_dir}"
        "--threads=${threads}"
        '--verbose'
    )
    # Run kallisto in stranded mode, depending on the library type.
    # Using salmon library type codes here, for consistency.
    # Doesn't currently support an auto detection mode, like salmon.
    case "$lib_type" in
        A)
            ;;
        ISF)
            quant_args+=('--fr-stranded')
            ;;
        ISR)
            quant_args+=('--rf-stranded')
            ;;
        *)
            koopa::invalid_arg "$lib_type"
            ;;
    esac
    quant_args+=("$fastq_r1" "$fastq_r2")
    koopa::dl 'Quant args' "${quant_args[*]}"
    kallisto quant "${quant_args[@]}" 2>&1 | "$tee" "$log_file"
    return 0
}

# FIXME Need to add this.
# FIXME How to do this for single end mode?
# -s, --sd=DOUBLE    Estimated standard deviation of fragment length
#                    (default: -l, -s values are estimated from paired
#                    end data, but are required when using --single)
koopa:::kallisto_quant_single_end() { # {{{1
    # Run kallisto quant (per single-end sample).

    # Must supply the length and standard deviation of the fragment length (not the read length).

    # FIXME We need to calculate the standard deviation here...

    echo 'FIXME'

    # FIXME Don't use '--bias' flag here.
    # FIXME Pass in the '--single' flag.
    # FIXME Pass in the '--verbose' flag here.
}

# NOTE Consider adding '--lib-type' flag here in a future update.
koopa::run_kallisto_paired_end() { # {{{1
    # """
    # Run kallisto on multiple samples.
    # @note Updated 2021-08-16.
    #
    # Number of bootstraps matches the current recommendation in bcbio-nextgen.
    # """
    local bootstraps fastq_dir fastq_r1_files output_dir r1_tail r2_tail
    koopa::assert_has_args "$#"
    bootstraps=30
    fastq_dir='fastq'
    output_dir='kallisto'
    r1_tail='_R1_001.fastq.gz'
    r2_tail='_R2_001.fastq.gz'
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
            --index-file=*)
                index_file="${1#*=}"
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
    if [[ -z "${fasta_file:-}" ]] && [[ -z "${index_file:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-file'."
    elif [[ -n "${fasta_file:-}" ]] && [[ -n "${index_file:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-file', but not both."
    fi
    koopa::assert_is_set 'fastq_dir' 'output_dir'
    fastq_dir="$(koopa::strip_trailing_slash "$fastq_dir")"
    output_dir="$(koopa::strip_trailing_slash "$output_dir")"
    koopa::h1 'Running kallisto.'
    koopa::activate_conda_env kallisto
    fastq_dir="$(koopa::realpath "$fastq_dir")"
    koopa::dl 'fastq dir' "$fastq_dir"
    # Sample array from FASTQ files {{{2
    # --------------------------------------------------------------------------
    # Create a per-sample array from the R1 FASTQ files.
    # Pipe GNU find into array.
    readarray -t fastq_r1_files <<< "$( \
        find "$fastq_dir" \
            -maxdepth 1 \
            -mindepth 1 \
            -type f \
            -name "*${r1_tail}" \
            -not -name '._*' \
            -print \
        | sort \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQs in '${fastq_dir}' with '${r1_tail}'."
    fi
    koopa::alert_info "${#fastq_r1_files[@]} samples detected."
    koopa::mkdir "$output_dir"
    # Index {{{2
    # --------------------------------------------------------------------------
    # Generate the genome index on the fly, if necessary.
    if [[ -n "${index_file:-}" ]]
    then
        index_file="$(koopa::realpath "$index_file")"
    else
        index_file="${output_dir}/kallisto.idx"
        koopa:::kallisto_index \
            --fasta-file="$fasta_file" \
            --index-file="$index_file"
    fi
    koopa::dl 'index' "$index_file"
    # Quantify {{{2
    # --------------------------------------------------------------------------
    # Loop across the per-sample array and quantify.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${r1_tail}/${r2_tail}}"
        koopa:::kallisto_quant \
            --bootstraps="$bootstraps" \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --index-file="$index_file" \
            --output-dir="$output_dir" \
            --r1-tail="$r1_tail" \
            --r2-tail="$r2_tail"
    done
    return 0
}

koopa::run_kallisto_single_end() { # {{{1
    # """
    # Run kallisto on multiple single-end FASTQ files.
    # @note Updated 2021-08-16.
    # """
    echo 'FIXME'
}
