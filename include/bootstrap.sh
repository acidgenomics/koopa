#!/bin/sh

set -o errexit
set -o nounset

# FIXME Inform the user if gcc is not installed.
# Debian: sudo apt install build-essential

# FIXME Consider adding: curl, git.


# FIXME Hitting this error on Ubuntu:
# gcc  -DPROGRAM='"bash"' -DCONF_HOSTTYPE='"x86_64"' -DCONF_OSTYPE='"linux-gnu"' -DCONF_MACHTYPE='"x86_64-pc-linux-gnu"' -DCONF_VENDOR='"pc"' -DLOCALEDIR='"/opt/koopa/bootstrap/share/locale"' -DPACKAGE='"bash"' -DSHELL -DHAVE_CONFIG_H   -I.  -I. -I./include -I./lib    -g -O2 -Wno-parentheses -Wno-format-security -c list.c
# bashline.c:65:10: fatal error: builtins/builtext.h: No such file or directory
#    65 | #include "builtins/builtext.h"          /* for read_builtin */
#       |          ^~~~~~~~~~~~~~~~~~~~~
# compilation terminated.
# make: *** [Makefile:101: bashline.o] Error 1
# make: *** Waiting for unfinished jobs....




# """
# Bootstrap core dependencies.
# @note Updated 2022-09-07.
# """

KOOPA_PREFIX="$(cd -- "$(dirname -- "$0")/.." && pwd)"
PREFIX="${KOOPA_PREFIX:?}/bootstrap"

PATH='/usr/bin:/bin'
export PATH

JOBS=2
TMPDIR="${TMPDIR:-/tmp}"

install_bash() {
    local file name tmp_dir url version
    name='bash'
    version='5.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure --prefix="$PREFIX"
    make --jobs="$JOBS"
    make install
    rm -fr "$tmp_dir"
    return 0
}

install_coreutils() {
    local file name tmp_dir url version
    name='coreutils'
    version='9.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure \
        --prefix="$PREFIX" \
        --program-prefix='g'
    make --jobs="$JOBS"
    make install
    rm -fr "$tmp_dir"
    return 0
}

main() {
    rm -fr "${PREFIX:?}"
    install_coreutils
    install_bash
}

main "$@"
