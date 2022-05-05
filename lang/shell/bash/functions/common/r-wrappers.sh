#!/usr/bin/env bash

koopa_camel_case() { # {{{1
    # """
    # Camel case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliCamelCase' "$@"
}

koopa_check_bin_man_consistency() { # {{{1
    # """
    # Check bin and man consistency.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliCheckBinManConsistency' "$@"
    return 0
}

koopa_docker_build_all_tags() { # {{{1
    # """
    # Build all Docker tags.
    # @note Updated 2020-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}

koopa_docker_prune_all_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for all images.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}

koopa_docker_prune_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for a specific image.
    # @note Updated 2021-08-14.
    #
    # This doesn't currently work when 2FA and PAT are enabled.
    # This issue may be resolved by the end of 2021-07.
    #
    # See also:
    # - https://github.com/docker/roadmap/issues/115
    # - https://github.com/docker/hub-feedback/issues/1914
    # - https://github.com/docker/hub-feedback/issues/1927
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}

koopa_download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadEnsemblGenome' "$@"
}

koopa_download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadGencodeGenome' "$@"
}

koopa_download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadRefseqGenome' "$@"
}

koopa_download_ucsc_genome() { # {{{1
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadUCSCGenome' "$@"
}

koopa_find_and_move_in_sequence() { # {{{1
    # """
    # Find and move files in sequence.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliFindAndMoveInSequence' "$@"
    return 0
}

koopa_kebab_case() { # {{{1
    # """
    # Kebab case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}

koopa_list_programs() { # {{{1
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa --vanilla 'cliListPrograms'
    return 0
}

koopa_prune_apps() { # {{{1
    # """
    # Prune applications.
    # @note Updated 2021-08-14.
    # """
    if koopa_is_macos
    then
        koopa_alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa_r_koopa 'cliPruneApps' "$@"
    return 0
}

koopa_snake_case() { # {{{1
    # """
    # Snake case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliSnakeCase' "$@"
}
