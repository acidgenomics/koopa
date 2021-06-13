#!/usr/bin/env bash

# FIXME Need to figure out how to get cpanm to resolve here better...

koopa::install_perl_packages() { # {{{1
    # """
    # Install Perl packages.
    # @note Updated 2021-06-11.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # CPAN Minus (cpanm) mirror options:
    # * --mirror http://cpan.cpantesters.org/  # use the fast-syncing mirror
    # * --from https://cpan.metacpan.org/      # use only the HTTPS mirror
    # """
    local module modules name_fancy prefix
    koopa::assert_is_installed 'cpan' 'perl'
    name_fancy='Perl packages'
    koopa::configure_perl
    prefix="$(koopa::perl_packages_prefix)"
    koopa::install_start "$name_fancy" "$prefix"


    # FIXME Need to rethink this.
    PERL_MM_OPT="INSTALL_BASE=$prefix" cpan 'local::lib'
    export PERL_MM_USE_DEFAULT=1
    koopa::activate_perl_packages



    if ! koopa::is_installed 'cpanm'
    then
        koopa::install_start 'CPAN Minus'
        # FIXME This is installing into Homebrew again ugh...
        # FIXME Need to rework...
        cpan -i 'App::cpanminus' &>/dev/null
    fi
    koopa::assert_is_installed 'cpanm'
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
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::uninstall_perl_packages() { # {{{1
    # """
    # Uninstall Perl packages.
    # @note Updated 2021-06-11.
    # """
    koopa::uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
}
