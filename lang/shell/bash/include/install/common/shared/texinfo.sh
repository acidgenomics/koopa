#!/usr/bin/env bash

# FIXME This is now failing to build for mac on Apple Silicon.

main() {
    # """
    # Install texinfo.
    # @note Updated 2023-04-13.
    #
    # @seealso
    # - https://github.com/conda-forge/texinfo-feedstock
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/texinfo.rb
    # """
    local -A app
    koopa_activate_app 'gettext' 'ncurses' 'perl'
    app['perl']="$(koopa_locate_perl --realpath)"
    koopa_assert_is_executable "${app[@]}"
    koopa_install_app_subshell \
        --installer='gnu-app' \
        --name='texinfo' \
        -D '--disable-dependency-tracking' \
        -D '--disable-install-warnings' \
        -D '--disable-perl-api-texi-build' \
        -D '--disable-perl-xs' \
        -D '--disable-silent-rules' \
        -D "PERL=${app['perl']}"
}
