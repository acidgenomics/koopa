#!/usr/bin/env bash

main() {
    # """
    # Install texinfo.
    # @note Updated 2023-08-30.
    #
    # @seealso
    # - https://github.com/conda-forge/texinfo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/texinfo.rb
    # """
    local -A app dict
    local -a conf_args install_args
    local conf_arg
    koopa_activate_app 'gettext' 'libiconv' 'ncurses' 'perl'
    app['perl']="$(koopa_locate_perl --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    conf_args=(
        '--disable-dependency-tracking'
        '--disable-install-warnings'
        '--disable-perl-xs'
        '--disable-silent-rules'
        "--with-libiconv-prefix=${dict['libiconv']}"
        "--with-libintl-prefix=${dict['gettext']}"
        "PERL=${app['perl']}"
    )
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
