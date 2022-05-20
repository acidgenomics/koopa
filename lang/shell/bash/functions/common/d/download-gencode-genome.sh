#!/usr/bin/env bash

koopa_download_gencode_genome() {
    # """
    # Download GENCODE genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadGencodeGenome' "$@"
}
