#!/usr/bin/env bash

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
    # @note Updated 2021-05-07.
    # """
    local repo repos prefix
    prefix="${INSTALL_PREFIX:?}"
    # Install BioPerl.
    git clone -b release-1-6-924 --depth 1 \
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
        git clone \
            "https://github.com/Ensembl/${repo}.git" \
            "${prefix}/${repo}" \
            || return 1
    done
    return 0
}
