#!/usr/bin/env bash

koopa::install_ensembl_perl_api() { # {{{1
    # """
    # Install Ensembl Perl API.
    # @note Updated 2020-07-30.
    # """
    local name_fancy prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::app_prefix)/ensembl"
    [[ -d "$prefix" ]] && return 0
    name_fancy='Ensembl Perl API'
    koopa::install_start "$name_fancy" "$prefix"
    koopa::mkdir "$prefix"
    (
        koopa::cd "$prefix"
        # Install BioPerl.
        git clone -b release-1-6-924 --depth 1 \
            'https://github.com/bioperl/bioperl-live.git'
        git clone 'https://github.com/Ensembl/ensembl-git-tools.git'
        git clone 'https://github.com/Ensembl/ensembl.git'
        git clone 'https://github.com/Ensembl/ensembl-variation.git'
        git clone 'https://github.com/Ensembl/ensembl-funcgen.git'
        git clone 'https://github.com/Ensembl/ensembl-compara.git'
        git clone 'https://github.com/Ensembl/ensembl-io.git'
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_perlbrew() { # {{{1
    # """
    # Install Perlbrew.
    # @note Updated 2020-07-30.
    #
    # Available releases:
    # > perlbrew available
    # """
    local all name_fancy prefix
    koopa::assert_has_args_le "$#" 1
    all=0
    while (("$#"))
    do
        case "$1" in
            --all)
                all=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::perlbrew_prefix)"
    [[ -d "$prefix" ]] && return 0
    name_fancy='Perlbrew'
    koopa::install_start "$name_fancy" "$prefix"
    koopa::assert_has_no_envs
    koopa::assert_is_not_installed perlbrew
    export PERLBREW_ROOT="$prefix"

    # Install Perlbrew {{{2
    # --------------------------------------------------------------------------

    koopa::mkdir "$prefix"
    koopa::rm "${HOME}/.perlbrew"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='install.sh'
        url='https://install.perlbrew.pl'
        koopa::download "$url" "$file"
        chmod +x "$file"
        "./${file}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$prefix"
    koopa::activate_perlbrew

    # Add system Perl to Perlbrew {{{2
    # --------------------------------------------------------------------------

    if [[ -x '/usr/local/bin/perl' ]]
    then
        bin_dir='/usr/local/bin'
    elif [[ -x '/usr/bin/perl' ]]
    then
        bin_dir='/usr/bin'
    else
        bin_dir=
    fi
    if [[ -d "$bin_dir" ]]
    then
        koopa::h2 'Linking system Perl in perlbrew.'
        (
            koopa::cd "${PERLBREW_ROOT}/perls"
            koopa::rm system
            koopa::mkdir system
            koopa::ln "$bin_dir" 'system/bin'
        )
    fi

    # Install latest Perl and pinned version for Ensembl Perl API {{{2
    # --------------------------------------------------------------------------

    if [[ "$all" -eq 1 ]]
    then
        perls=(
            "perl-$(koopa::variable ensembl-perl)"
            "perl-$(koopa::variable perl)"
        )
        installed="$(perlbrew list)"
        for perl in "${perls[@]}"
        do
            koopa::str_match "$installed" "$perl" && continue
            koopa::h2 "Installing '${perl}'."
            koopa::coffee_time
            perlbrew install "$perl"
            koopa::install_success "$perl"
        done
    fi
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_perlbrew_perl() { # {{{1
    # """
    # Install Perlbrew Perl.
    # @note Updated 2020-07-10.
    #
    # Note that 5.30.1 is currently failing with Perlbrew on macOS.
    # Using the '--notest' flag to avoid this error.
    #
    # See also:
    # - https://www.reddit.com/r/perl/comments/duddcn/perl_5301_released/
    # """
    local perl_name version
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed perlbrew
    version="$(koopa::variable perl)"
    perl_name="perl-${version}"
    # Alternatively, can use '--force' here.
    perlbrew --notest install "$perl_name"
    perlbrew switch "$perl_name"
    # > perlbrew list
    return 0
}
