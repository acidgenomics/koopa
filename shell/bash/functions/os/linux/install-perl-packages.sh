#!/usr/bin/env bash

koopa::install_perl_packages() {
    # """
    # Install Perl packages.
    # @note Updated 2020-07-20.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local cellar module modules name_fancy
    koopa::assert_is_installed cpan perl
    name_fancy='Perl packages'
    koopa::install_start "$name_fancy"
    if koopa::is_cellar perl
    then
        cellar=1
    else
        cellar=0
    fi
    export PERL_MM_USE_DEFAULT=1
    if ! koopa::is_installed cpanm
    then
        koopa::info 'CPAN Minus'
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    [[ "$cellar" -eq 1 ]] && koopa::link_cellar perl
    koopa::assert_is_installed cpanm
    if [[ "$#" -gt 0 ]]
    then
        modules=("$@")
    else
        modules=(
            'App::Ack'
            'File::Rename'
        )
    fi
    for module in "${modules[@]}"
    do
        koopa::info "${module}"
        cpanm "$module" &>/dev/null
    done
    [[ "$cellar" -eq 1 ]] && koopa::link_cellar perl
    koopa::install_success "$name_fancy"
    return 0
}

