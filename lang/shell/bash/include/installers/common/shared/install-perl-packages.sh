#!/usr/bin/env bash

main() {
    # """
    # Install Perl packages.
    # @note Updated 2022-06-17.
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
    koopa_configure_perl
    koopa_activate_perl
    declare -A app=(
        [cpan]="$(koopa_locate_cpan)"
    )
    [[ -x "${app[cpan]}" ]] || return 1
    modules=(
        'MIYAGAWA/App-cpanminus-1.7046' # 2022-04-27; App::cpanminus
        'PETDANCE/ack-v3.5.0' # 2021-03-12; App::Ack
        'RMBARKER/File-Rename-1.31' # 2022-05-07; File::Rename
    )
    for module in "${modules[@]}"
    do
        koopa_alert "Installing '${module}'."
        "${app[cpan]}" -i "${module}.tar.gz"
    done
    return 0
}
