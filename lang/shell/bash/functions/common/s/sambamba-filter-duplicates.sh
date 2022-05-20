#!/usr/bin/env bash

koopa_sambamba_filter_duplicates() {
    # """
    # Remove duplicates from a duplicate marked BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       bam/__init__.py
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not duplicate' "$@"
    return 0
}
