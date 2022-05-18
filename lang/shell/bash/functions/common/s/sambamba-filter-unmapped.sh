#!/usr/bin/env bash

koopa_sambamba_filter_unmapped() {
    # """
    # Filter unmapped reads from a BAM file.
    # @note Updated 2020-08-12.
    # """
    koopa_assert_has_args "$#"
    koopa_sambamba_filter --filter='not unmapped' "$@"
    return 0
}
