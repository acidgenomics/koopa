#!/usr/bin/env bash

koopa_sambamba_sort_per_sample() {
    # """
    # Sort a BAM file by genomic coordinates.
    # @note Updated 2023-04-06.
    #
    # Sorts by genomic coordinates by default.
    # Use '-n' flag to sort by read name instead.
    #
    # @seealso
    # - https://lomereiter.github.io/sambamba/docs/sambamba-sort.html
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['sambamba']="$(koopa_locate_sambamba)"
    koopa_assert_is_executable "${app[@]}"
    dict['input']="${1:?}"
    dict['threads']="$(koopa_cpu_count)"
    koopa_assert_is_file "${dict['input']}"
    koopa_assert_is_matching_regex \
        --pattern='\.bam$' \
        --string="${dict['input']}"
    dict['output']="${dict['input']%.bam}.sorted.bam"
    dict['input_bn']="$(koopa_basename "${dict['input']}")"
    dict['output_bn']="$(koopa_basename "${dict['output']}")"
    if [[ -f "${dict['output']}" ]]
    then
        koopa_alert_note "Skipping '${dict['output_bn']}'."
        return 0
    fi
    koopa_alert "Sorting '${dict['input_bn']}' to '${dict['output_bn']}'."
    "${app['sambamba']}" sort \
        --memory-limit='2GB' \
        --nthreads="${dict['threads']}" \
        --out="${dict['output']}" \
        --show-progress \
        "${dict['input']}"
    return 0
}
