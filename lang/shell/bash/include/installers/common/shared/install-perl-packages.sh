#!/usr/bin/env bash

# FIXME Need to version pin these.
# FIXME Here's how to version pin:
# https://www.perl.com/article/4/2013/3/27/How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/

# FIXME Can we avoid installing cpanm? Seems more sensible...rework.

main() {
    # """
    # Install Perl packages.
    # @note Updated 2022-06-14.
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
        [cpanm]="$(koopa_locate_cpanm --allow-missing)"
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
        'Test::More'  # For GNU stow.
        'Test::Output' # For GNU stow.
    )
    for module in "${modules[@]}"
    do
        koopa_alert "${module}"
        "${app[cpanm]}" "$module"
    done
    return 0
}
