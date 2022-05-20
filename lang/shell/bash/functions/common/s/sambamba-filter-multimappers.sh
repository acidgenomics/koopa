#!/usr/bin/env bash

koopa_sambamba_filter_multimappers() {
    # """
    # Filter multi-mapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # @seealso
    # - https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/
    #       chipseq/__init__.py
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='[XS] == null' "$@"
    return 0
}
