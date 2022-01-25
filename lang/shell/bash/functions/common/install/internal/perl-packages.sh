#!/usr/bin/env bash

koopa:::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2022-01-25.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local app module modules
    koopa::configure_perl
    koopa::activate_perl
    declare -A app=(
        [cpan]="$(koopa::locate_cpan)"
        [cpanm]="$(koopa::locate_cpanm 2>/dev/null || true)"
    )
    if ! koopa::is_installed "${app[cpanm]}"
    then
        koopa::alert_install_start 'CPAN Minus'
        "${app[cpan]}" -i 'App::cpanminus' &>/dev/null
    fi
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
        "${app[cpanm]}" "$module" &>/dev/null
    done
    return 0
}
