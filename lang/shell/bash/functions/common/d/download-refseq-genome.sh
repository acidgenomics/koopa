#!/usr/bin/env bash

koopa_download_refseq_genome() {
    # """
    # Download RefSeq genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadRefseqGenome' "$@"
}
