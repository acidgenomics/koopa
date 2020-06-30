#!/usr/bin/env bash

_koopa_bam_filter() {  # {{{1
    # """
    # Perform filtering on a BAM file.
    # @note Updated 2020-06-29.
    #
    # See also:
    # - https://lomereiter.github.io/sambamba/docs/sambamba-view.html
    # - https://github.com/lomereiter/sambamba/wiki/
    #       %5Bsambamba-view%5D-Filter-expression-syntax
    # - https://hbctraining.github.io/In-depth-NGS-Data-Analysis-Course/
    #       sessionV/lessons/03_align_and_filtering.html
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed sambamba
    while (("$#"))
    do
        case "$1" in
            --filter=*)
                local filter="${1#*=}"
                shift 1
                ;;
            --input-bam=*)
                local input_bam="${1#*=}"
                shift 1
                ;;
            --output-bam=*)
                local output_bam="${1#*=}"
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set filter input_bam output_bam
    _koopa_assert_are_not_identical "$input_bam" "$output_bam"
    local input_bam_bn
    input_bam_bn="$(basename "$input_bam")"
    local output_bam_bn
    output_bam_bn="$(basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        _koopa_note "Skipping '${output_bam_bn}'."
        return 0
    fi
    _koopa_h2 "Filtering '${input_bam_bn}' to '${output_bam_bn}'."
    _koopa_assert_is_file "$input_bam"
    _koopa_dl "Filter" "'$filter'"
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"
    # Note that sambamba prints version information into stderr.
    sambamba view \
        --filter="$filter" \
        --format="bam" \
        --nthreads="$threads" \
        --output-filename="$output_bam" \
        --show-progress \
        --with-header \
        "$input_bam"
    return 0
}

_koopa_bam_filter_duplicates() {  # {{{1
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # @note Updated 2020-06-29.
    #
    # See also:
    # https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     bam/__init__.py
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_bam_filter --filter="not duplicate" "$@"
    return 0
}

_koopa_bam_filter_multimappers() {  # {{{1
    # """
    # Filter multi-mapped reads from BAM file.
    # @note Updated 2020-06-29.
    #
    # See also:
    # https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #     chipseq/__init__.py
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_bam_filter --filter="[XS] == null" "$@"
    return 0
}

_koopa_bam_filter_unmapped() {  # {{{1
    # """
    # Filter unmapped reads from BAM file.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_bam_filter --filter="not unmapped" "$@"
    return 0
}

_koopa_bam_index() {  # {{{1
    # """
    # Index BAM file.
    # @note Updated 2020-02-05.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed samtools
    local bam_file
    bam_file="${1:?}"
    _koopa_h2 "Indexing '${bam_file}'."
    _koopa_assert_is_file "$bam_file"
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"
    sambamba index \
        --nthreads="$threads" \
        --show-progress \
        "$bam_file"
    return 0
}

_koopa_bam_sort() {  # {{{1
    # """
    # Sort BAM file by genomic coordinates.
    # @note Updated 2020-02-05.
    #
    # Sorts by genomic coordinates by default.
    # Use '-n' flag to sort by read name instead.
    #
    # See also:
    # https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed sambamba
    local unsorted_bam
    unsorted_bam="${1:?}"
    local sorted_bam
    sorted_bam="${unsorted_bam%.bam}.sorted.bam"
    local unsorted_bam_bn
    unsorted_bam_bn="$(basename "$unsorted_bam")"
    local sorted_bam_bn
    sorted_bam_bn="$(basename "$sorted_bam")"
    if [[ -f "$sorted_bam" ]]
    then
        _koopa_note "Skipping '${sorted_bam_bn}'."
        return 0
    fi
    _koopa_h2 "Sorting '${unsorted_bam_bn}' to '${sorted_bam_bn}'."
    _koopa_assert_is_file "$unsorted_bam"
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "${threads}"
    # This is noisy and spits out program version information, so hiding stdout
    # and stderr. Note that simply using '> /dev/null' doesn't work here.
    sambamba sort \
        --memory-limit="2GB" \
        --nthreads="$threads" \
        --out="$sorted_bam" \
        --show-progress \
        "$unsorted_bam"
    return 0
}

_koopa_bowtie2() {  # {{{1
    # """
    # Run bowtie2 on paired-end FASTQ files.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
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
        return 0
    fi
    _koopa_h2 "Aligning '${id}' into '${sample_output_dir}'."
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"
    local sam_file
    sam_file="${sample_output_dir}/${id}.sam"
    local log_file
    log_file="${sample_output_dir}/bowtie2.log"
    mkdir -pv "$sample_output_dir"
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

_koopa_bowtie2_index() {  # {{{1
    # """
    # Generate bowtie2 index.
    # @note Updated 2020-02-05.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed bowtie2-build
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set fasta_file index_dir
    _koopa_assert_is_file "$fasta_file"
    if [[ -d "$index_dir" ]]
    then
        _koopa_note "Index exists at '${index_dir}'. Skipping."
        return 0
    fi
    _koopa_h2 "Generating bowtie2 index at '${index_dir}'."
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"
    # Note that this step adds 'bowtie2.*' to the file names created in the
    # index directory.
    local index_prefix
    index_prefix="${index_dir}/bowtie2"
    mkdir -pv "$index_dir"
    bowtie2-build \
        --threads="$threads" \
        "$fasta_file" \
        "$index_prefix"
    return 0
}

_koopa_sam_to_bam() {  # {{{1
    # """
    # Convert SAM file to BAM.
    # @note Updated 2020-06-29.
    # """
    [[ "$#" -gt 0 ]] || return 1
    _koopa_assert_is_installed samtools
    while (("$#"))
    do
        case "$1" in
            --input-sam=*)
                local input_sam="${1#*=}"
                shift 1
                ;;
            --output-bam=*)
                local output_bam="${1#*=}"
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set input_sam output_bam
    local sam_bn
    sam_bn="$(basename "$input_sam")"
    local bam_bn
    bam_bn="$(basename "$output_bam")"
    if [[ -f "$output_bam" ]]
    then
        _koopa_note "Skipping '${bam_bn}'."
        return 0
    fi
    _koopa_h2 "Converting '${sam_bn}' to '${bam_bn}'."
    _koopa_assert_is_file "$input_sam"
    local threads
    threads="$(_koopa_cpu_count)"
    _koopa_dl "Threads" "$threads"
    samtools view \
        -@ "$threads" \
        -b \
        -h \
        -o "$output_bam" \
        "$input_sam"
    return 0
}
