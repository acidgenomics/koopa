#!/usr/bin/env bash

koopa_activate_ensembl_perl_api() {
    # """
    # Activate Ensembl Perl API.
    # @note Updated 2022-07-25.
    #
    # @seealso
    # - https://useast.ensembl.org/info/docs/api/api_installation.html
    # """
    local dict
    declare -A dict=(
        [prefix]="$(koopa_ensembl_perl_api_prefix)"
    )
    koopa_assert_is_dir "${dict[prefix]}"
    koopa_add_to_path_start "${dict[prefix]}/ensembl-git-tools/bin"
    PERL5LIB="${PERL5LIB:-}"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/bioperl-1.6.924"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-compara/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-variation/modules"
    PERL5LIB="${PERL5LIB}:${dict[prefix]}/ensembl-funcgen/modules"
    export PERL5LIB
    return 0
}
