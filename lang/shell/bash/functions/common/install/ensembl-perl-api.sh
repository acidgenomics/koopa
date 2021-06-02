#!/usr/bin/env bash

# [2021-05-27] macOS success.

koopa::install_ensembl_perl_api() { # {{{1
    koopa::install_app \
        --name='ensembl-perl-api' \
        --name-fancy='Ensembl Perl API' \
        --no-link \
        --prefix="$(koopa::ensembl_perl_api_prefix)" \
        --version='rolling'
}

koopa:::install_ensembl_perl_api() { # {{{1
    # """
    # Install Ensembl Perl API.
    # @note Updated 2021-06-02.
    # """
    local git repo repos prefix
    prefix="${INSTALL_PREFIX:?}"
    git="$(koopa::locate_git)"
    "$git" clone \
        --branch 'release-1-6-924' \
        --depth 1 \
        'https://github.com/bioperl/bioperl-live.git' \
        "${prefix}/bioperl-live" \
        || return 1
    repos=(
        'ensembl'
        'ensembl-compara'
        'ensembl-funcgen'
        'ensembl-git-tools'
        'ensembl-io'
        'ensembl-variation'
    )
    for repo in "${repos[@]}"
    do
        koopa::git_clone \
            "https://github.com/Ensembl/${repo}.git" \
            "${prefix}/${repo}" \
            || return 1
    done
    return 0
}
