#!/usr/bin/env bash

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadEnsemblGenome' "$@"
    return 0
}

koopa::download_flybase_genome() { # {{{1
    # """
    # Download FlyBase genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadFlybaseGenome' "$@"
    return 0
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadGencodeGenome' "$@"
    return 0
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadRefseqGenome' "$@"
    return 0
}
