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
    local app module modules name names
    koopa_assert_has_no_args "$#"
    koopa_configure_perl
    koopa_activate_perl
    declare -A app=(
        [cpan]="$(koopa_locate_cpan)"
    )
    [[ -x "${app[cpan]}" ]] || return 1
    names=(
        'cpanminus'
        'ack'
        'rename'
    )
    modules=()
    for name in "${names[@]}"
    do
        local repo version
        case "$name" in
            'ack')
                # App::Ack.
                repo='PETDANCE/ack'
                ;;
            'cpanminus')
                # App::cpanminus.
                repo='MIYAGAWA/App-cpanminus'
                ;;
            'rename')
                # File::Rename.
                repo='RMBARKER/File-Rename'
                ;;
            *)
                koopa_stop 'Unsupported Perl package.'
                ;;
        esac
        version="$(koopa_variable "perl-${name}")"
        modules+=("${repo}-${version}")
    done
    for module in "${modules[@]}"
    do
        koopa_alert "Installing '${module}'."
        "${app[cpan]}" -i "${module}.tar.gz"
    done
    return 0
}
