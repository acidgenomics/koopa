#!/usr/bin/env bash

koopa::install_perlbrew() { # {{{1
    koopa::install_app \
        --name='perlbrew' \
        --name-fancy='Perlbrew' \
        --version='rolling' \
        --no-link \
        "$@"
}

koopa:::install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2021-05-25.
    #
    # Available releases:
    # > perlbrew available
    # """
    local file prefix url
    prefix="${INSTALL_PREFIX:?}"
    koopa::mkdir "$prefix"
    koopa::rm "${HOME:?}/.perlbrew"
    file='install.sh'
    url='https://install.perlbrew.pl'
    koopa::download "$url" "$file"
    koopa::chmod +x "$file"
    export PERLBREW_ROOT="$prefix"
    "./${file}"
}

koopa::install_perlbrew_perl() { # {{{1
    # """
    # Install Perlbrew Perl.
    # @note Updated 2021-05-25.
    #
    # Note that 5.30.1 is currently failing with Perlbrew on macOS.
    # Using the '--notest' flag to avoid this error.
    #
    # See also:
    # - https://www.reddit.com/r/perl/comments/duddcn/perl_5301_released/
    # """
    local perl_name version
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::activate_perlbrew
    koopa::assert_is_installed 'perlbrew'
    version="$(koopa::variable perl)"
    perl_name="perl-${version}"
    # Alternatively, can use '--force' here.
    perlbrew --notest install "$perl_name"
    perlbrew switch "$perl_name"
    # > perlbrew list
    return 0
}

koopa::update_perlbrew() { # {{{1
    # """
    # Update Perlbrew.
    # @note Updated 2021-05-25.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::activate_perlbrew
    if ! koopa::is_installed 'perlbrew'
    then
        koopa::alert_is_not_installed 'perlbrew'
        return 0
    fi
    koopa::h1 'Updating Perlbrew.'
    perlbrew self-upgrade
    return 0
}

