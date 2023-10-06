#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2023-10-06.
# """

# Can debug with:
# > set -o xtrace

set -o errexit
set -o nounset

PREFIX="${PREFIX:-}"
[ -z "$PREFIX" ] && PREFIX="$(mktemp -d)"
PATH="${PREFIX}/bin:/usr/bin:/bin"
export PATH PREFIX

install_bash() {
    printf 'Installing %s in %s.\n' 'Bash' "$PREFIX"
    mkdir -p "${PREFIX}/src/bash"
    cd "${PREFIX}/src/bash" || return 1
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
# >     printf 'Installing %s in %s.\n' 'GNU coreutils' "$PREFIX"
# >     mkdir -p "${PREFIX}/src/coreutils"
# >     cd "${PREFIX}/src/coreutils" || return 1
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
    printf 'Installing %s in %s.\n' 'Python' "$PREFIX"
    mkdir -p "${PREFIX}/src/python"
    cd "${PREFIX}/src/python"
    curl \
        'https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'Python-3.12.0' || return 1
    ./configure --prefix="$PREFIX" --without-ensurepip
    make
    make install
    [ -x "${PREFIX}/bin/python3" ] || return 1
    return 0
}

main() {
    printf 'Installing %s into %s.\n' 'koopa bootstrap' "$PREFIX"
    (
        # > install_coreutils
        install_bash
        install_python
    )
    return 0
}

main "$@"
