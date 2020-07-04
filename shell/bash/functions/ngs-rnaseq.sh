#!/usr/bin/env bash

koopa::kallisto_index() { # {{{1
    # """
    # Generate kallisto index.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed kallisto
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                local fasta_file="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                local index_file="${1#*=}"
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
        koopa::note "Index exists at '${index_file}'. Skipping."
        return 0
    fi
    koopa::h2 "Generating kallisto index at '${index_file}'."
    local index_dir
    index_dir="$(dirname "$index_file")"
    local log_file
    log_file="${index_dir}/kallisto-index.log"
    mkdir -pv "$index_dir"
    kallisto index \
        -i "$index_file" \
        "$fasta_file" \
        2>&1 | tee "$log_file"
    return 0
}

koopa::kallisto_quant() { # {{{1
    # """
    # Run kallisto quant.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed kallisto
    while (("$#"))
    do
        case "$1" in
            --fastq-r1=*)
                local fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                local fastq_r2="${1#*=}"
                shift 1
                ;;
            --index-file=*)
                local index_file="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                local output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                local r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                local r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set fastq_r1 fastq_r2 index_file output_dir r1_tail r2_tail
    koopa::assert_is_file "$fastq_r1" "$fastq_r2"
    local fastq_r1_bn
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"
    local fastq_r2_bn
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"
    koopa::assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"
    local id
    id="$fastq_r1_bn"
    local sample_output_dir
    sample_output_dir="${output_dir}/${id}"
    if [[ -d "$sample_output_dir" ]]
    then
        koopa::note "Skipping '${id}'."
        return 0
    fi
    koopa::h2 "Quantifying '${id}' into '${sample_output_dir}'."
    local bootstraps
    bootstraps=30
    koopa::dl "Bootstraps" "$bootstraps"
    local threads
    threads="$(koopa::cpu_count)"
    koopa::dl "Threads" "$threads"
    local log_file
    log_file="${sample_output_dir}/kallisto-quant.log"
    mkdir -pv "$sample_output_dir"
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

koopa::salmon_index() { # {{{1
    # """
    # Generate salmon index.
    # @note Updated 2020-06-29.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed salmon
    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                local fasta_file="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                local index_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set fasta_file index_dir
    koopa::assert_is_file "$fasta_file"
    if [[ -d "$index_dir" ]]
    then
        koopa::note "Index exists at '${index_dir}'. Skipping."
        return 0
    fi
    koopa::h2 "Generating salmon index at '${index_dir}'."
    local threads
    threads="$(koopa::cpu_count)"
    koopa::dl "Threads" "$threads"
    local log_file
    log_file="$(dirname "$index_dir")/salmon-index.log"
    mkdir -pv "$index_dir"
    salmon index \
            -k 31 \
            -p "$threads" \
            -i "$index_dir" \
            -t "$fasta_file" \
            2>&1 | tee "$log_file"
    return 0
}

koopa::salmon_quant() { # {{{1
    # """
    # Run salmon quant.
    # @note Updated 2020-05-04.
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed salmon
    while (("$#"))
    do
        case "$1" in
            --fastq-r1=*)
                local fastq_r1="${1#*=}"
                shift 1
                ;;
            --fastq-r2=*)
                local fastq_r2="${1#*=}"
                shift 1
                ;;
            --index-dir=*)
                local index_dir="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                local output_dir="${1#*=}"
                shift 1
                ;;
            --r1-tail=*)
                local r1_tail="${1#*=}"
                shift 1
                ;;
            --r2-tail=*)
                local r2_tail="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_set fastq_r1 fastq_r2 index_dir output_dir r1_tail r2_tail
    koopa::assert_is_file "$fastq_r1" "$fastq_r2"
    local fastq_r1_bn
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"
    local fastq_r2_bn
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"
    koopa::assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"
    local id
    id="$fastq_r1_bn"
    local sample_output_dir
    sample_output_dir="${output_dir}/${id}"
    if [[ -d "$sample_output_dir" ]]
    then
        koopa::note "Skipping '${id}'."
        return 0
    fi
    koopa::h2 "Quantifying '${id}' into '${sample_output_dir}'."
    local bootstraps
    bootstraps=30
    koopa::dl "Bootstraps" "$bootstraps"
    local threads
    threads="$(koopa::cpu_count)"
    koopa::dl "Threads" "$threads"
    local log_file
    log_file="${sample_output_dir}/salmon-quant.log"
    mkdir -pv "$sample_output_dir"
    salmon quant \
        --gcBias \
        --index="$index_dir" \
        --libType="A" \
        --mates1="$fastq_r1" \
        --mates2="$fastq_r2" \
        --numBootstraps="$bootstraps" \
        --output="$sample_output_dir" \
        --seqBias \
        --threads="$threads" \
        2>&1 | tee "$log_file"
    return 0
}
