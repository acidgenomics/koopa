#!/usr/bin/env bash

koopa::bowtie2() { # {{{1
    # """
    # Run bowtie2 on paired-end FASTQ files.
    # @note Updated 2021-05-22.
    # """
    local fastq_r1 fastq_r1_bn fastq_r2 fastq_r2_bn id index_prefix log_file
    local output_dir r1_tail r2_tail sam_file sample_output_dir threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'bowtie2'
    while (("$#"))
    do
        case "$1" in
            --fastq-r1=*)
                fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                fastq_r2="${1#*=}"
                shift 1
                ;;
            --index-prefix=*)
                index_prefix="${1#*=}"
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
    koopa::assert_is_set 'fastq_r1' 'fastq_r2' 'index_prefix' 'output_dir' \
        'r1_tail' 'r2_tail'
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
    koopa::h2 "Aligning '${id}' into '${sample_output_dir}'."
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    sam_file="${sample_output_dir}/${id}.sam"
    log_file="${sample_output_dir}/bowtie2.log"
    koopa::mkdir "$sample_output_dir"
    bowtie2 \
        --local \
        --sensitive-local \
        --rg-id "$id" \
        --rg 'PL:illumina' \
        --rg "PU:${id}" \
        --rg "SM:${id}" \
        -1 "$fastq_r1" \
        -2 "$fastq_r2" \
        -S "$sam_file" \
        -X 2000 \
        -p "$threads" \
        -q \
        -x "$index_prefix" \
        2>&1 | tee "$log_file"
    return 0
}

koopa::bowtie2_index() { # {{{1
    # """
    # Generate bowtie2 index.
    # @note Updated 2020-08-12.
    # """
    local fasta_file index_dir index_prefix threads
    koopa::assert_has_args "$#"
    koopa::assert_is_installed 'bowtie2-build'
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                fasta_file="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                index_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set 'fasta_file' 'index_dir'
    koopa::assert_is_file "$fasta_file"
    if [[ -d "$index_dir" ]]
    then
        koopa::alert_note "Index exists at '${index_dir}'. Skipping."
        return 0
    fi
    koopa::h2 "Generating bowtie2 index at '${index_dir}'."
    threads="$(koopa::cpu_count)"
    koopa::dl 'Threads' "$threads"
    # This step adds 'bowtie2.*' to the files created in the index directory.
    index_prefix="${index_dir}/bowtie2"
    koopa::mkdir "$index_dir"
    bowtie2-build \
        --threads="$threads" \
        "$fasta_file" \
        "$index_prefix"
    return 0
}

koopa::run_bowtie2() { # {{{1
    # """
    # Run bowtie2 on a directory containing multiple FASTQ files.
    # @note Updated 2020-08-13.
    # """
    local fastq_dir fastq_r1_files output_dir r1_tail r2_tail
    fastq_dir='fastq'
    output_dir='bowtie2'
    r1_tail='_R1_001.fastq.gz'
    r2_tail='_R2_001.fastq.gz'
    while (("$#"))
    do
        case "$1" in
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
    if [[ -z "${fasta_file:-}" ]] && [[ -z "${index_dir:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-dir'."
    elif [[ -n "${fasta_file:-}" ]] && [[ -n "${index_dir:-}" ]]
    then
        koopa::stop "Specify 'fasta-file' or 'index-dir', but not both."
    fi
    koopa::assert_is_set 'fastq_dir' 'output_dir'
    fastq_dir="$(koopa::strip_trailing_slash "$fastq_dir")"
    output_dir="$(koopa::strip_trailing_slash "$output_dir")"
    koopa::h1 'Running bowtie2.'
    koopa::activate_conda_env bowtie2
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
            -print \
        | sort \
    )"
    # Error on FASTQ match failure.
    if [[ "${#fastq_r1_files[@]}" -eq 0 ]]
    then
        koopa::stop "No FASTQs in '${fastq_dir}' with '${r1_tail}'."
    fi
    koopa::alert_info "${#fastq_r1_files[@]} samples detected."

    # Index {{{2
    # --------------------------------------------------------------------------

    # Generate the genome index on the fly, if necessary.
    if [[ -n "${index_dir:-}" ]]
    then
        index_dir="$(koopa::realpath "$index_dir")"
    else
        index_dir="${output_dir}/bowtie2.idx"
        koopa::bowtie2_index \
            --fasta-file="$fasta_file" \
            --index-dir="$index_dir"
    fi
    koopa::dl 'index' "$index_dir"

    # Alignment {{{2
    # --------------------------------------------------------------------------

    # Loop across the per-sample array and align.
    for fastq_r1 in "${fastq_r1_files[@]}"
    do
        fastq_r2="${fastq_r1/${r1_tail}/${r2_tail}}"
        index_prefix="${index_dir}/bowtie2"
        koopa::bowtie2 \
            --fastq-r1="$fastq_r1" \
            --fastq-r2="$fastq_r2" \
            --index-prefix="$index_prefix" \
            --output-dir="$output_dir" \
            --r1-tail="$r1_tail" \
            --r2-tail="$r2_tail"
    done
    return 0
}

