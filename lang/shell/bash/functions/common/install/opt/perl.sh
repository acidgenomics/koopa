#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
# FIXME Need to move this to a separate file.
koopa::configure_perl() { # {{{1
    # """
    # Configure Perl.
    # @note Updated 2021-12-21.
    #
    # Ignore these unit test errors:
    # > Failed test 'fish: activate PATH'
    # > Failed test 'fish: deactivate PATH'
    #
    # @seealso:
    # - https://www.reddit.com/r/perl/comments/i0439v/
    #   some_perl_modules_doesnt_work_after_update/fzn80k4/
    # """
    local perl prefix yes
    koopa::assert_has_no_args "$#"
    perl="$(koopa::locate_perl)"
    yes="$(koopa::locate_yes)"
    koopa::configure_app_packages \
        --name='perl' \
        --name-fancy='Perl' \
        --which-app="$perl"
    prefix="$(koopa::perl_packages_prefix)"
    koopa::assert_is_dir "$prefix"
    # Ensure we start with a clean CPAN and CPAN Minus configuration.
    koopa::rm \
        "${HOME}/.cpan" \
        "${HOME}/.cpanm"
    koopa::alert "Setting up 'local::lib' at '${prefix}' using CPAN."
    koopa::add_to_path_start "$(koopa::dirname "$perl")"
    "$yes" \
        | PERL_MM_OPT="INSTALL_BASE=$prefix" \
            cpan -f -i 'local::lib' \
            &>/dev/null \
        || true
    eval "$( \
        "$perl" \
            "-I${prefix}/lib/perl5" \
            "-Mlocal::lib=${prefix}" \
            &>/dev/null \
    )"
    return 0
}

# FIXME Need to move this to a separate file.
# FIXME Rework using app/dict approach.
koopa:::install_perl() { # {{{1
    # """
    # Install Perl.
    # @note Updated 2021-05-26.
    # @seealso
    # - https://www.cpan.org/src/
    # - https://metacpan.org/pod/distribution/perl/INSTALL
    # - https://perlmaven.com/how-to-build-perl-from-source-code
    # """
    local file jobs make name prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='perl'
    file="${name}-${version}.tar.gz"
    url="https://www.cpan.org/src/5.0/${file}"
    koopa::download "$url" "$file"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::alert_coffee_time
    ./Configure -des -Dprefix="$prefix"
    "$make" --jobs="$jobs"
    # The installer will warn when you skip this step.
    # > "$make" test
    "$make" install
    return 0
}
