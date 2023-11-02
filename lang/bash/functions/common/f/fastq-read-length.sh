#!/usr/bin/env bash

koopa_fastq_read_length() {
    # """
    # Determine the read length of a FASTQ file.
    # @note Updated 2023-11-02.
    #
    # seqkit alternatives:
    # - This will return length per read, but is too verbose:
    #   $ seqkit fx2tab --length --name FASTQ_FILE...
    # - This includes more details, but is very slow:
    #   $ seqkit stats --all FASTQ_FILE...
    #
    # @seealso
    # - https://www.biostars.org/p/459116/
    # - https://www.biostars.org/p/295536/
    # """
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_file "$@"
    app['awk']="$(koopa_locate_awk)"
    app['head']="$(koopa_locate_head)"
    app['sort']="$(koopa_locate_sort)"
    app['uniq']="$(koopa_locate_uniq)"
    koopa_assert_is_executable "${app[@]}"
    for file in "$@"
    do
        local length
        # shellcheck disable=SC2016
        length="$( \
            koopa_decompress --stdout "$file" \
                | "${app['awk']}" 'NR%4==2 {print length}' \
                | "${app['sort']}" -n \
                | "${app['uniq']}" -c \
                | "${app['sort']}" -hr \
                | "${app['head']}" -1 \
                | "${app['awk']}" '{print $2}' \
        )"
        [[ -n "$length" ]] || return 1
        koopa_print "$length"
    done
    return 0
}
