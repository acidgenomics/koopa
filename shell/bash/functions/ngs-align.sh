#!/usr/bin/env bash

# FIXME Convert these other ones to a general function.

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
