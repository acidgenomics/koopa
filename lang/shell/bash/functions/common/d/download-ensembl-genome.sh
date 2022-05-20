#!/usr/bin/env bash

koopa_download_ensembl_genome() {
    # """
    # Download Ensembl genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadEnsemblGenome' "$@"
}
