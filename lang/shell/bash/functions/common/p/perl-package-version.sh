#!/usr/bin/env bash

koopa_perl_package_version() {
    # """
    # Perl package version.
    # @note Updated 2022-03-21.
    #
    # @seealso
    # - https://www.perl.com/article/1/2013/3/24/3-quick-ways-to-find-out-the-
    #     version-number-of-an-installed-Perl-module-from-the-terminal/
    # - cpan -D <module_name>
    #
    # @examples
    # > koopa_perl_package_version 'File::Rename'
    # # 1.30
    # """
    local app pkg
    koopa_assert_has_args "$#"
    declare -A app=(
        [perl]="$(koopa_locate_perl)"
    )
    for pkg in "$@"
    do
        local dict
        declare -A dict
        dict[pkg]="$pkg"
        # Note that there cannot be a space after '-M' here.
        dict[str]="$( \
            "${app[perl]}" \
                -M"${dict[pkg]}" \
                -e "print \$${dict[pkg]}::VERSION .\"\n\";" \
        )"
        [[ -n "${dict[str]}" ]] || return 1
        koopa_print "${dict[str]}"
    done
    return 0
}
