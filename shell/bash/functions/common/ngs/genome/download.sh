#!/usr/bin/env bash

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::pyscript 'download-ensembl-genome' "$@"
    return 0
}

koopa::download_flybase_genome() { # {{{1
    # """
    # Download FlyBase genome.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::pyscript 'download-flybase-genome' "$@"
    return 0
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::pyscript 'download-gencode-genome' "$@"
    return 0
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::pyscript 'download-refseq-genome' "$@"
    return 0
}
