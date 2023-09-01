#!/usr/bin/env bash

main() {
    # Install gawk.
    # @note Updated 2023-08-30.
    #
    # Persistent memory allocator (PMA) is enabled by default. At the time of
    # writing, that would force an x86_64 executable on macOS arm64, because a
    # native ARM binary with such feature would not work.
    #
    # See also:
    # https://git.savannah.gnu.org/cgit/gawk.git/tree/README_d/
    # README.macosx?h=gawk-5.2.1#n1
    #
    # @seealso
    # - https://github.com/macports/macports-ports/blob/master/lang/
    #     gawk/Portfile
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/gawk.rb
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    koopa_activate_app 'gettext' 'mpfr' 'readline'
    koopa_install_gnu_app -D '--disable-pma'
    (
        koopa_cd "${dict['prefix']}/share/man/man1"
        koopa_ln 'gawk.1' 'awk.1'
    )
    return 0
}
