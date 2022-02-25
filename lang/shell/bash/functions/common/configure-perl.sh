#!/usr/bin/env bash

koopa_configure_perl() { # {{{1
    # """
    # Configure Perl.
    # @note Updated 2022-01-25.
    #
    # Ignore these unit test errors:
    # > Failed test 'fish: activate PATH'
    # > Failed test 'fish: deactivate PATH'
    #
    # @seealso:
    # - https://www.reddit.com/r/perl/comments/i0439v/
    #   some_perl_modules_doesnt_work_after_update/fzn80k4/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
        [yes]="$(koopa_locate_yes)"
    )
    declare -A dict=(
        [prefix]="$(koopa_perl_packages_prefix)"
    )
    koopa_configure_app_packages \
        --name='perl' \
        --name-fancy='Perl' \
        --which-app="${app[perl]}"
    koopa_assert_is_dir "${dict[prefix]}"
    # Ensure we start with a clean CPAN and CPAN Minus configuration.
    koopa_rm "${HOME}/.cpan" "${HOME}/.cpanm"
    koopa_alert "Setting up 'local::lib' at '${dict[prefix]}' using CPAN."
    koopa_add_to_path_start "$(koopa_dirname "${app[perl]}")"
    app[cpan]="$(koopa_locate_cpan)"
    "${app[yes]}" \
        | PERL_MM_OPT="INSTALL_BASE=${dict[prefix]}" \
            "${app[cpan]}" -f -i 'local::lib' \
            &>/dev/null \
        || true
    eval "$( \
        "${app[perl]}" \
            "-I${dict[prefix]}/lib/perl5" \
            "-Mlocal::lib=${dict[prefix]}" \
            &>/dev/null \
    )"
    return 0
}
