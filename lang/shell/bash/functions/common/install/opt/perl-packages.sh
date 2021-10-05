#!/usr/bin/env bash

koopa::install_perl_packages() { # {{{1
    koopa:::install_app_packages \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa:::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2021-09-17.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local module modules
    koopa::configure_perl
    koopa::activate_perl
    if ! koopa::is_installed 'cpanm'
    then
        koopa::assert_is_installed 'cpan'
        koopa::install_start 'CPAN Minus'
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    koopa::assert_is_installed 'cpanm'
    if [[ "$#" -gt 0 ]]
    then
        modules=("$@")
    else
        modules=(
            'App::Ack'
            'File::Rename'
            'Log::Log4perl'
        )
    fi
    for module in "${modules[@]}"
    do
        koopa::alert "${module}"
        cpanm "$module" &>/dev/null
    done
    return 0
}

koopa::uninstall_perl_packages() { # {{{1
    # """
    # Uninstall Perl packages.
    # @note Updated 2021-06-11.
    # """
    koopa:::uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
}

koopa::update_perl_packages() { # {{{1
    # """
    # Update Perl packages.
    # @note Updated 2021-09-15.
    # """
    koopa::install_perl_packages "$@"
}
