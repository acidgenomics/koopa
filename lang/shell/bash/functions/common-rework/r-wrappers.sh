#!/usr/bin/env bash

koopa_download_ucsc_genome() {
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliDownloadUCSCGenome' "$@"
}

koopa_find_and_move_in_sequence() {
    # """
    # Find and move files in sequence.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliFindAndMoveInSequence' "$@"
    return 0
}

koopa_kebab_case() {
    # """
    # Kebab case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliKebabCase' "$@"
}

koopa_list_programs() {
    # """
    # List koopa programs available in PATH.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_no_args "$#"
    koopa_r_koopa --vanilla 'cliListPrograms'
    return 0
}

koopa_prune_apps() {
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

koopa_snake_case() {
    # """
    # Snake case.
    # @note Updated 2021-08-14.
    # """
    koopa_assert_has_args "$#"
    koopa_r_koopa 'cliSnakeCase' "$@"
}
