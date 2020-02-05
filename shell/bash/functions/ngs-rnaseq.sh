#!/usr/bin/env bash

_koopa_kallisto_index() {
    # """
    # Generate kallisto index.
    # Updated 2020-02-04.
    # """
    _koopa_assert_is_installed kallisto

    while (("$#"))
    do
        case "$1" in
            --fasta-file=*)
                local fasta_file="${1#*=}"
                shift 1
                ;;
            --output-dir=*)
                local output_dir="${1#*=}"
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done

    _koopa_assert_is_set fasta_file output_dir
    _koopa_assert_is_file "$fasta_file"

    mkdir -pv "$output_dir"

    local index_file
    index_file="${output_dir}/kallisto.idx"

    if [[ -f "$index_file" ]]
    then
        _koopa_note "Index exists at '${index_file}'."
        return 0
    fi

    local log_file
    log_file="${output_dir}/kallisto-index.log"

    kallisto index \
        -i "$index_file" \
        "$fasta_file" \
        2>&1 | tee "$log_file"

    return 0
}

_koopa_kallisto_quant() {
    # """
    # Run kallisto quant.
    # Updated 2020-02-04.
    # """
    _koopa_assert_is_installed kallisto

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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done

    _koopa_assert_is_set fastq_r1 fastq_r2 \
        index_file output_dir \
        r1_tail r2_tail
    _koopa_assert_is_file "$fastq_r1" "$fastq_r2"

    local fastq_r1_bn
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"

    local fastq_r2_bn
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"

    _koopa_assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"

    local id
    id="$fastq_r1_bn"

    local sample_output_dir
    sample_output_dir="${output_dir}/${id}"

    if [[ -d "$sample_output_dir" ]]
    then
        _koopa_note "Skipping '${id}'."
        return 1
    fi

    _koopa_info "Quantifying '${id}'."

    local bootstraps
    bootstraps=30
    _koopa_dl "Bootstraps" "$bootstraps"

    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"

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
