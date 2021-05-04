#!/usr/bin/env bash

koopa::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2021-05-05.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local module modules name_fancy prefix
    koopa::assert_is_installed cpan perl
    name_fancy='Perl packages'
    koopa::install_start "$name_fancy"
    prefix="$(koopa::perl_packages_prefix)"
    if [[ ! -d "$prefix" ]]
    then
        PERL_MM_OPT="INSTALL_BASE=$prefix" \
            cpan 'local::lib'
    fi
    _koopa_activate_perl_packages
    export PERL_MM_USE_DEFAULT=1
    if ! koopa::is_installed cpanm
    then
        koopa::install_start 'CPAN Minus'
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    koopa::assert_is_installed cpanm
    if [[ "$#" -gt 0 ]]
    then
        modules=("$@")
    else
        modules=(
            'App::Ack'
            'File::Rename'  # Also managed by Homebrew.
        )
    fi
    for module in "${modules[@]}"
    do
        koopa::alert "${module}"
        cpanm "$module" &>/dev/null
    done
    koopa::install_success "$name_fancy"
    return 0
}

