#!/usr/bin/env bash

# FIXME Need to allow user to install in custom target 'opt/perl-packages'.
# FIXME THIS SHOULD ALSO WORK ON MACOS.
koopa::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2021-05-05.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local link module modules name_fancy
    koopa::assert_is_installed cpan perl
    name_fancy='Perl packages'
    koopa::install_start "$name_fancy"
    link=0
    koopa::is_symlinked_app perl && link=1
    export PERL_MM_USE_DEFAULT=1
    if ! koopa::is_installed cpanm
    then
        koopa::install_start 'CPAN Minus'
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    [[ "$link" -eq 1 ]] && koopa::link_app perl
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
        koopa::install_start "${module}"
        cpanm "$module" &>/dev/null
    done
    [[ "$link" -eq 1 ]] && koopa::link_app perl
    koopa::install_success "$name_fancy"
    return 0
}

