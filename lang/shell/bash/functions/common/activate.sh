#!/usr/bin/env bash

koopa::activate_ensembl_perl_api() { # {{{1
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2021-11-18.
    #
    # The Ensembl API is compatible with Perl version 5.14 through to 5.26. 
    #
    # Use Perlbrew to manage a specific pinned legacy version.
    # > perlbrew switch 'perl-5.26'
    #
    # @seealso
    # - https://useast.ensembl.org/info/docs/api/api_installation.html
    # """
    local dict
    declare -A dict=(
        [prefix]="$(koopa::ensembl_perl_api_prefix)"
    )
    koopa::assert_is_dir "${dict[prefix]}"
    koopa::activate_prefix "${dict[prefix]}/ensembl-git-tools"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

koopa::activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2021-11-18.
    # """
    local app
    declare -A app=(
        [llvm_config]="$(koopa::locate_llvm_config)"
    )
    LLVM_CONFIG="${app[llvm_config]}"
    export LLVM_CONFIG
    return 0
}
