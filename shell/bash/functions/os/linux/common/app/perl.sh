#!/usr/bin/env bash

koopa::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2020-11-19.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local link_app module modules name_fancy
    koopa::assert_is_installed cpan perl
    name_fancy='Perl packages'
    koopa::install_start "$name_fancy"
    link_app=0
    koopa::is_symlinked_app perl && link_app=1
    export PERL_MM_USE_DEFAULT=1
    if ! koopa::is_installed cpanm
    then
        koopa::info 'CPAN Minus'
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    [[ "$link_app" -eq 1 ]] && koopa::link_cellar perl
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
    [[ "$link_app" -eq 1 ]] && koopa::link_cellar perl
    koopa::install_success "$name_fancy"
    return 0
}

