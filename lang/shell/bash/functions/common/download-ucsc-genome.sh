#!/usr/bin/env bash

koopa_download_ucsc_genome() {
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadUCSCGenome' "$@"
}
