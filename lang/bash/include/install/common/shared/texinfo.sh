#!/usr/bin/env bash

main() {
    # """
    # Install texinfo.
    # @note Updated 2023-04-13.
    #
    # @seealso
    # - https://github.com/conda-forge/texinfo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/texinfo.rb
    # """
    local -A app dict
    koopa_activate_app 'gettext' 'libiconv' 'ncurses' 'perl'
    app['perl']="$(koopa_locate_perl --realpath)"
    koopa_assert_is_executable "${app[@]}"
    dict['gettext']="$(koopa_app_prefix 'gettext')"
    dict['libiconv']="$(koopa_app_prefix 'libiconv')"
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='texinfo' \
        -D '--disable-dependency-tracking' \
        -D '--disable-install-warnings' \
        -D '--disable-perl-xs' \
        -D '--disable-silent-rules' \
        -D "--with-libiconv-prefix=${dict['libiconv']}" \
        -D "--with-libintl-prefix=${dict['gettext']}" \
        -D "PERL=${app['perl']}"
}
