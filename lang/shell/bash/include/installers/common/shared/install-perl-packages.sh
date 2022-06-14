#!/usr/bin/env bash

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
    #
    # @seealso
    # - https://www.cpan.org/modules/INSTALL.html
    # - https://www.perl.com/article/4/2013/3/27/
    #     How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/
    # """
    local app module modules
    koopa_assert_has_no_args "$#"
    koopa_activate_perl
    declare -A app=(
        [cpan]="$(koopa_locate_cpan)"
    )
    modules=(
        'MIYAGAWA/App-cpanminus-1.7046' # 2022-04-27; App::cpanminus
        'PETDANCE/ack-v3.5.0' # 2021-03-12; App::Ack
        'RMBARKER/File-Rename-1.31' # 2022-05-07; File::Rename
        # > 'ETJ/Log-Log4perl-1.55' # 2022-06-01; Log::Log4perl
        'EXODIST/Test-Simple-1.302190' # 2022-03-04; Test::More; GNU stow
        'BDFOY/Test-Output-1.033' # 2021-02-10; Test::Output; GNU stow
    )
    for module in "${modules[@]}"
    do
        koopa_alert "Installing '${module}'."
        "${app[cpan]}" -i "${module}.tar.gz"
    done
    return 0
}
