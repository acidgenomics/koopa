#!/usr/bin/env bash

koopa::camel_case() { # {{{1
    # """
    # Camel case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliCamelCase' "$@"
}

koopa::check_bin_man_consistency() { # {{{1
    # """
    # Check bin and man consistency.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'cliCheckBinManConsistency' "$@"
    return 0
}

koopa::docker_build_all_tags() { # {{{1
    # """
    # Build all Docker tags.
    # @note Updated 2020-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerBuildAllTags' "$@"
    return 0
}

koopa::docker_prune_all_stale_tags() { # {{{1
    # """
    # Prune (delete) all stale tags on DockerHub for all images.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa 'cliDockerPruneAllStaleTags' "$@"
    return 0
}

koopa::docker_prune_stale_tags() { # {{{1
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
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDockerPruneStaleTags' "$@"
    return 0
}

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadEnsemblGenome' "$@"
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadGencodeGenome' "$@"
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadRefseqGenome' "$@"
}

koopa::download_ucsc_genome() { # {{{1
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadUCSCGenome' "$@"
}

koopa::drat() { # {{{
    # """
    # Add R package to drat repository.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDrat' "$@"
}

koopa::find_and_move_in_sequence() { # {{{1
    # """
    # Find and move files in sequence.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliFindAndMoveInSequence' "$@"
    return 0
}

koopa::kebab_case() { # {{{1
    # """
    # Kebab case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliKebabCase' "$@"
}

koopa::list_programs() { # {{{1
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::r_koopa --vanilla 'cliListPrograms'
    return 0
}

koopa::pkgdown_deploy_to_aws() { # {{{1
    # """
    # Deploy a pkgdown website to AWS.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliPkgdownDeployToAWS' "$@"
}

koopa::prune_apps() { # {{{1
    # """
    # Prune applications.
    # @note Updated 2021-08-14.
    # """
    if koopa::is_macos
    then
        koopa::alert_note 'App pruning not yet supported on macOS.'
        return 0
    fi
    koopa::r_koopa 'cliPruneApps' "$@"
    return 0
}

koopa::snake_case() { # {{{1
    # """
    # Snake case.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliSnakeCase' "$@"
}

koopa::unlink_app() { # {{{1
    # """
    # Unlink an application.
    # @note Updated 2021-08-14.
    # """
    local make_prefix
    koopa::assert_has_args "$#"
    make_prefix="$(koopa::make_prefix)"
    if koopa::is_macos
    then
        koopa::alert_note "Linking into '${make_prefix}' is not \
supported on macOS."
        return 0
    fi
    koopa::r_koopa 'cliUnlinkApp' "$@"
    return 0
}
