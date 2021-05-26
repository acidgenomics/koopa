#!/usr/bin/env bash

koopa::activate_ensembl_perl_api() { # {{{1
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2021-05-26.
    #
    # Note that this currently requires Perl 5.26.
    # > perlbrew switch perl-5.26
    # """
    local prefix
    prefix="$(koopa::ensembl_perl_api_prefix)"
    koopa::assert_is_dir "$prefix"
    koopa::activate_prefix "${prefix}/ensembl-git-tools"
    PERL5LIB="${PERL5LIB}:${prefix}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${prefix}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}

koopa::activate_llvm() { # {{{1
    # """
    # Activate LLVM config.
    # @note Updated 2021-05-25.
    # """
    LLVM_CONFIG="$(koopa::locate_llvm_config)"
    export LLVM_CONFIG
    return 0
}
