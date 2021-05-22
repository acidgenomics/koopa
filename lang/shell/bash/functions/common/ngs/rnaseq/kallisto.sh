#!/usr/bin/env bash

koopa:::kallisto_index() { # {{{1
    # """
    # Generate kallisto index.
    # @note Updated 2020-08-12.
    # """
    local fasta_file index_dir index_file log_file
    koopa::assert_has_args "$#"
    koopa::assert_is_installed kallisto
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
    koopa::assert_is_set fasta_file index_file
    koopa::assert_is_file "$fasta_file"
    if [[ -f "$index_file" ]]
    then
        koopa::alert_note "Index exists at '${index_file}'. Skipping."
        return 0
    fi
    koopa::h2 "Generating kallisto index at '${index_file}'."
    index_dir="$(dirname "$index_file")"
    log_file="${index_dir}/kallisto-index.log"
    koopa::mkdir "$index_dir"
    kallisto index \
        -i "$index_file" \
        "$fasta_file" \
        2>&1 | tee "$log_file"
    return 0
}

koopa:::kallisto_quant() { # {{{1
    # """
    # Run kallisto quant.
    # @note Updated 2021-05-22.
    # """
    local bootstraps fastq_r1 fastq_r1_bn fastq_r2 fastq_r2_bn id index_file
    local log_file output_dir r1_tail r2_tail sample_output_dir threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed kallisto
    while (("$#"))
    do
        case "$1" in
            --bootstraps=*)
                bootstraps="${1#*=}"
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
    koopa::assert_is_set bootstraps fastq_r1 fastq_r2 index_file output_dir \
        r1_tail r2_tail
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
    kallisto quant \
        --bootstrap-samples="$bootstraps" \
        --index="$index_file" \
        --output-dir="$sample_output_dir" \
        --threads="$threads" \
        "$fastq_r1" \
        "$fastq_r2" \
        2>&1 | tee "$log_file"
    return 0
}

# NOTE Consider adding '--lib-type' flag here in a future update.
koopa::run_kallisto() { # {{{1
    # """
    # Run kallisto on multiple samples.
    # @note Updated 2021-01-20.
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
    koopa::assert_is_set fastq_dir output_dir
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

