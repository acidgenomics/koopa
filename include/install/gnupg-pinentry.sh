#!/usr/bin/env bash

# > koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2.sig"
koopa::download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2"
# > if koopa::is_installed gpg-agent
# > then
# >     gpg --verify "${name}-${version}.tar.bz2.sig"
# > fi
koopa::extract "${name}-${version}.tar.bz2"
koopa::cd "${name}-${version}"
flags=("--prefix=${prefix}")
if koopa::is_opensuse
then
    # Build with ncurses is currently failing on openSUSE, due to
    # hard-coded link to /usr/include/ncursesw that isn't easy to resolve:
    #
    # In file included from /usr/include/ncursesw/curses.h:60:0,
    # from pinentry-curses.c:25:
    #     /usr/include/ncursesw/curses.h:1457:21:
    #     error: field '_nc_ttytype' declared as a function
    #
    # Falling back to using 'pinentry-tty' instead in this case.
    flags+=(
        '--disable-fallback-curses'
        '--disable-pinentry-curses'
        '--enable-pinentry-tty'
    )
else
    flags+=('--enable-pinentry-curses')
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
