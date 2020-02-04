#!/usr/bin/env bash

_koopa_bam_filter() {
    # """
    # Perform filtering on a BAM file.
    # Updated 2020-02-04.
    # """

    # FIXME Use a tmpfile approach here.
    # FIXME Need to be able to handle '--filter' flag here.

    _koopa_assert_is_installed sambamba

    local input_file
    input_file="${1:?}"

    local output_file
    output_file="${2:?}"

    local filter
    filter="${3:?}"

    local threads
    threads="$(_koopa_cpu_count)"

    sambamba view \
        -F "$filter" \
        -f bam \
        -h \
        -t "$threads" \
        "$input_file" > "$output_file"

    return 0
}

_koopa_bam_filter_duplicates() {                                          # {{{1
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # Updated 2020-02-04.
    #
    # See also:
    # https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     bam/__init__.py
    # """
    _koopa_bam_filter --filter="not duplicate" "$@"
    return 0
}

_koopa_bam_filter_multimappers() {                                        # {{{1
    # """
    # Filter multi-mapped reads from BAM file.
    # Updated 2020-02-04.
    #
    # See also:
    # https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     chipseq/__init__.py
    # """
    _koopa_bam_filter --filter="[XS] == null" "$@"
    return 0
}

_koopa_bam_filter_unmapped() {
    _koopa_bam_filter --filter="not unmapped" "$@"
    return 0
}

_koopa_bowtie2() {                                                        # {{{1
    # """
    # Run bowtie2 on paired-end FASTQ files.
    # Updated 2020-02-04.
    # """
    _koopa_assert_is_installed bowtie2

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
            --index-prefix=*)
                local index_prefix="${1#*=}"
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

    _koopa_assert_is_set fastq_r1 fastq_r2 index_prefix output_dir \
        r1_tail r2_tail
    _koopa_assert_is_file "$fastq_r1" "$fastq_r2"

    local threads
    threads="$(_koopa_cpu_count)"

    local fastq_r1_bn
    fastq_r1_bn="$(basename "$fastq_r1")"
    fastq_r1_bn="${fastq_r1_bn/${r1_tail}/}"

    local fastq_r2_bn
    fastq_r2_bn="$(basename "$fastq_r2")"
    fastq_r2_bn="${fastq_r2_bn/${r2_tail}/}"

    _koopa_assert_are_identical "$fastq_r1_bn" "$fastq_r2_bn"

    local id
    id="$fastq_r1_bn"
    _koopa_info "Aligning '${id}'."

    local sample_output_dir
    sample_output_dir="${output_dir}/${id}"
    [ -d "$sample_output_dir" ] && return 1
    mkdir -pv "$sample_output_dir"

    local sam_file
    sam_file="${sample_output_dir}/${id}.sam"

    local log_file
    log_file="${sample_output_dir}/bowtie2.log"

    bowtie2 \
        --local \
        --sensitive-local \
        --rg-id "$id" \
        --rg "PL:illumina" \
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
