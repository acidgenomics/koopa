#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2023-09-25.
# """

# Can debug with:
# > set -o xtrace

set -o errexit
set -o nounset

TMPDIR="$(mktemp -d)"
PREFIX="${TMPDIR}/bootstrap"
PATH="${PREFIX}/bin:/usr/bin:/bin"
export PATH PREFIX TMPDIR

install_bash() {
    printf 'Installing Bash.\n'
    mkdir -p "${TMPDIR}/src/bash"
    cd "${TMPDIR}/src/bash" || return 1
    curl \
        'https://ftp.gnu.org/gnu/bash/bash-5.2.15.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'bash-5.2.15' || return 1
    ./configure --prefix="$PREFIX"
    make
    make install
    [ -x "${PREFIX}/bin/bash" ] || return 1
    return 0
}

# > install_coreutils() {
# >     printf 'Installing GNU coreutils.\n'
# >     mkdir -p "${TMPDIR}/src/coreutils"
# >     cd "${TMPDIR}/src/coreutils" || return 1
# >     curl \
# >         'https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.gz' \
# >         -o 'src.tar.gz'
# >     tar -xzf 'src.tar.gz'
# >     cd 'coreutils-9.4' || return 1
# >     ./configure --prefix="${PREFIX:?}" --program-prefix='g'
# >     make
# >     make install
# >     [ -x "${PREFIX}/bin/gcp" ] || return 1
# >     return 0
# > }

install_python() {
    printf 'Installing Python.\n'
    mkdir -p "${TMPDIR}/src/python"
    cd "${TMPDIR}/src/python"
    curl \
        'https://www.python.org/ftp/python/3.11.5/Python-3.11.5.tgz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'Python-3.11.5' || return 1
    ./configure --prefix="$PREFIX"
    make
    make install
    [ -x "${PREFIX}/bin/python3" ] || return 1
    return 0
}

main() {
    printf "Installing koopa bootstrap into '%s'.\n" "$PREFIX"
    (
        # > install_coreutils
        install_bash
        install_python
    )
    printf '%s\n' "$PREFIX"
    return 0
}

main "$@"
