#!/usr/bin/env bash

# FIXME Need to remove ~/.cpan ~/.cpanm on reinstall.

install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2022-03-28.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local app module modules
    koopa_assert_has_no_args "$#"
    koopa_activate_perl
    declare -A app=(
        [cpan]="$(koopa_locate_cpan)"
        [cpanm]="$(koopa_locate_cpanm 2>/dev/null || true)"
    )
    if ! koopa_is_installed "${app[cpanm]}"
    then
        koopa_alert_install_start 'CPAN Minus'
        "${app[cpan]}" -i 'App::cpanminus' &>/dev/null
        app[cpanm]="$(koopa_locate_cpanm)"
    fi
    modules=(
        'App::Ack'
        'File::Rename'
        'Log::Log4perl'
    )
    for module in "${modules[@]}"
    do
        koopa_alert "${module}"
        "${app[cpanm]}" "$module"
    done
    return 0
}
