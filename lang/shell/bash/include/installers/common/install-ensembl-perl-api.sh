#!/usr/bin/env bash

koopa:::install_ensembl_perl_api() { # {{{1
    # """
    # Install Ensembl Perl API.
    # @note Updated 2021-11-23.
    # """
    local dict ensembl_repos repo
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
    )
    koopa::git_clone \
        --branch='release-1-6-924' \
        'https://github.com/bioperl/bioperl-live.git' \
        "${dict[prefix]}/bioperl-live"
    ensembl_repos=(
        'ensembl'
        'ensembl-compara'
        'ensembl-funcgen'
        'ensembl-git-tools'
        'ensembl-io'
        'ensembl-variation'
    )
    for repo in "${ensembl_repos[@]}"
    do
        koopa::git_clone \
            "https://github.com/Ensembl/${repo}.git" \
            "${dict[prefix]}/${repo}"
    done
    return 0
}
