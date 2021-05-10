#!/usr/bin/env bash

# NOTE This is failing to build on macOS.
# # In file included from regex.c:74:
# # In file included from ./regexec.c:1362:
# # ./malloc/dynarray-skeleton.c:195:13: error: expected identifier or '('
# # __nonnull ((1))

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # """
    local brew_prefix conf_args
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=('--with-ssl=openssl')
    elif koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix \
            gnutls \
            libpsl \
            openssl \
            pkg-config
        brew_prefix="$(koopa::homebrew_prefix)"
        # This install script currently doesn't pick up 'pkg-config' in PATH
        # correctly for some reason, so define manually.
        export PKG_CONFIG="${brew_prefix}/opt/pkg-config/bin/pkg-config"
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${conf_args[@]}" \
        "$@"
}
