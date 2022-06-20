#!/usr/bin/env bash

# FIXME Need to split this out to install Perl package per prefix.

main() {
    # """
    # Install Perl packages.
    # @note Updated 2022-06-20.
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
    koopa_activate_perl
    declare -A app=(
        [cpan]="$(koopa_locate_cpan)"
    )
    [[ -x "${app[cpan]}" ]] || return 1
    names=(
        'ack'
        'cpanminus'
        'exiftool'
        'rename'
    )
    modules=()
    for name in "${names[@]}"
    do
        local repo version version2
        version="$(koopa_variable "perl-${name}")"
        version2="$version"
        case "$name" in
            'ack')
                # App::Ack.
                repo='PETDANCE/ack'
                version2="v${version}"
                ;;
            'cpanminus')
                # App::cpanminus.
                repo='MIYAGAWA/App-cpanminus'
                ;;
            'exiftool')
                # Image::ExifTool.
                repo='EXIFTOOL/Image-ExifTool'
                ;;
            'rename')
                # File::Rename.
                repo='RMBARKER/File-Rename'
                ;;
            *)
                koopa_stop 'Unsupported Perl package.'
                ;;
        esac
        modules+=("${repo}-${version2}")
    done
    for module in "${modules[@]}"
    do
        koopa_alert "Installing '${module}'."
        "${app[cpan]}" -i "${module}.tar.gz"
    done
    return 0
}
