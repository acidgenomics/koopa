#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2.sig"
_koopa_download "${gcrypt_url}/${name}/${name}-${version}.tar.bz2"
if _koopa_is_installed gpg-agent
then
    gpg --verify "${name}-${version}.tar.bz2.sig"
fi
_koopa_extract "${name}-${version}.tar.bz2"
cd "${name}-${version}" || exit 1
flags=("--prefix=${prefix}")
if _koopa_is_opensuse
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
        "--disable-fallback-curses"
        "--disable-pinentry-curses"
        "--enable-pinentry-tty"
    )
else
    flags+=("--enable-pinentry-curses")
fi
./configure "${flags[@]}"
make --jobs="$jobs"
make install
