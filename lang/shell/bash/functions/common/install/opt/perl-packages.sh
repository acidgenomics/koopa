#!/usr/bin/env bash

# FIXME Need to locate cpan and cpanm here.
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
        koopa::alert_install_start 'CPAN Minus'
        koopa::assert_is_installed 'cpan'
        # FIXME Need to locate this.
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
        # FIXME Need to locate this.
        cpanm "$module" &>/dev/null
    done
    return 0
}
