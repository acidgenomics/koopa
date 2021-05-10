#!/usr/bin/env bash

# NOTE Failing to install on macOS with GCC 11.
# # utimens.c: In function 'fdutimens':
# # utimens.c:399:17: warning: 'update_timespec' accessing 16 bytes in a region of size 8 [-Wstringop-overflow=]
# #   399 |       if (ts && update_timespec (&st, &ts))
# #       |                 ^~~~~~~~~~~~~~~~~~~~~~~~~~
# # utimens.c:399:17: note: referencing argument 2 of type 'struct timespec **'
# # utimens.c:136:1: note: in a call to function 'update_timespec'
# #   136 | update_timespec (struct stat const *statbuf, struct timespec *ts[2])
# #       | ^~~~~~~~~~~~~~~
# #   CC       chdir-long.o
# #   CC       error.o
# # utimens.c: In function 'lutimens':
# # utimens.c:612:17: warning: 'update_timespec' accessing 16 bytes in a region of size 8 [-Wstringop-overflow=]
# #   612 |       if (ts && update_timespec (&st, &ts))
# #       |                 ^~~~~~~~~~~~~~~~~~~~~~~~~~
# # utimens.c:612:17: note: referencing argument 2 of type 'struct timespec **'
# # utimens.c:136:1: note: in a call to function 'update_timespec'
# #   136 | update_timespec (struct stat const *statbuf, struct timespec *ts[2])
# #       | ^~~~~~~~~~~~~~~

koopa::install_wget() { # {{{1
    # """
    # Install wget.
    # @note Updated 2021-05-10.
    # """
    local conf_args gcc_version install_args
    install_args=()
    conf_args=()
    if koopa::is_linux
    then
        conf_args+=(
            '--with-ssl=openssl'
        )
    elif koopa::is_macos
    then
        gcc_version="$(koopa::variable 'gcc')"
        gcc_version="$(koopa::major_version "$gcc_version")"
        # clang currently fails to build this, so use GCC instead.
        install_args+=(
            "--homebrew-opt=gcc@${gcc_version},gnutls,libpsl,openssl,pkg-config"
        )
        conf_args+=(
            "CC=gcc-${gcc_version}"
        )
    fi
    koopa::install_gnu_app \
        --name='wget' \
        "${install_args[@]}" \
        "${conf_args[@]}" \
        "$@"
}
