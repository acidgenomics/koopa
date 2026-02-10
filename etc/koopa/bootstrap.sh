#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2026-01-11.
# """

# Can debug with:
# > set -o xtrace

set -o errexit
set -o nounset

cpu_count() {
    __kvar_num="${KOOPA_CPU_COUNT:-}"
    if [ -n "$__kvar_num" ]
    then
        printf '%s\n' "$__kvar_num"
        unset -v __kvar_num
        return 0
    fi
    if [ -d "${KOOPA_PREFIX:-}" ]
    then
        __kvar_bin_prefix="${KOOPA_PREFIX:?}/bin"
    else
        __kvar_bin_prefix=''
    fi
    __kvar_getconf='/usr/bin/getconf'
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/gnproc" ]
    then
        __kvar_nproc="${__kvar_bin_prefix}/gnproc"
    else
        __kvar_nproc=''
    fi
    if [ -d "$__kvar_bin_prefix" ] && [ -x "${__kvar_bin_prefix}/python3" ]
    then
        __kvar_python="${__kvar_bin_prefix}/python3"
    elif [ -x '/usr/bin/python3' ]
    then
        __kvar_python='/usr/bin/python3'
    else
        __kvar_python=''
    fi
    __kvar_sysctl='/usr/sbin/sysctl'
    if [ -x "$__kvar_nproc" ]
    then
        __kvar_num="$("$__kvar_nproc" --all)"
    elif [ -x "$__kvar_getconf" ]
    then
        __kvar_num="$("$__kvar_getconf" '_NPROCESSORS_ONLN')"
    elif [ -x "$__kvar_sysctl" ] && is_macos
    then
        __kvar_num="$( \
            "$__kvar_sysctl" -n 'hw.ncpu' \
            | cut -d ' ' -f 2 \
        )"
    elif [ -x "$__kvar_python" ]
    then
        __kvar_num="$( \
            "$__kvar_python" -c \
                "import multiprocessing; print(multiprocessing.cpu_count())" \
            2>/dev/null \
            || true \
        )"
    fi
    [ -z "$__kvar_num" ] && __kvar_num=1
    printf '%d\n' "$__kvar_num"
    unset -v \
        __kvar_bin_prefix \
        __kvar_getconf \
        __kvar_nproc \
        __kvar_num \
        __kvar_python \
        __kvar_sysctl
    return 0
}

install_bash() {
    __kvar_version='5.3'
    printf 'Installing bash.\n'
    mkdir -p "${PREFIX}/src/bash"
    cd "${PREFIX}/src/bash" || return 1
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "https://ftpmirror.gnu.org/gnu/bash/\
bash-${__kvar_version}.tar.gz" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "bash-${__kvar_version}" || return 1
    ./configure --prefix="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    [ -x "${PREFIX}/bin/bash" ] || return 1
    unset -v __kvar_version
    return 0
}

install_coreutils() {
    __kvar_version='9.10'
    printf 'Installing coreutils.\n'
    mkdir -p "${PREFIX}/src/coreutils"
    cd "${PREFIX}/src/coreutils" || return 1
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "https://ftpmirror.gnu.org/gnu/coreutils/\
coreutils-${__kvar_version}.tar.gz" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "coreutils-${__kvar_version}" || return 1
    if is_root
    then
        export FORCE_UNSAFE_CONFIGURE=1
    fi
    ./configure --prefix="$PREFIX" --program-prefix='g'
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    [ -x "${PREFIX}/bin/gcp" ] || return 1
    unset -v __kvar_version
    return 0
}

install_openssl() {
    __kvar_version='3.6.1'
    printf 'Installing openssl3.\n'
    mkdir -p "${PREFIX}/src/openssl3"
    cd "${PREFIX}/src/openssl3" || return 1
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "https://github.com/openssl/openssl/releases/download/\
openssl-${__kvar_version}/openssl-${__kvar_version}.tar.gz" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "openssl-${__kvar_version}" || return 1
    ./config \
        --libdir='lib' \
        --openssldir="$PREFIX" \
        --prefix="$PREFIX" \
        "-Wl,-rpath,${PREFIX}/lib" \
        'no-zlib' \
        'shared'
    make VERBOSE=1 --jobs=1 depend
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install_sw
    [ -x "${PREFIX}/bin/openssl" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python() {
    __kvar_version='3.14.3'
    printf 'Installing python.\n'
    mkdir -p "${PREFIX}/src/python"
    cd "${PREFIX}/src/python"
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "https://www.python.org/ftp/python/${__kvar_version}/\
Python-${__kvar_version}.tgz" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "Python-${__kvar_version}" || return 1
    export LDLIBS='-lcrypto -lssl -lz'
    ./configure \
        --prefix="$PREFIX" \
        --with-openssl="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    unset -v LDLIBS
    [ -x "${PREFIX}/bin/python3" ] || return 1
    unset -v __kvar_version
    return 0
}

install_zlib() {
    __kvar_version='1.3.1'
    printf 'Installing zlib.\n'
    mkdir -p "${PREFIX}/src/zlib"
    cd "${PREFIX}/src/zlib"
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "https://www.zlib.net/zlib-${__kvar_version}.tar.gz" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "zlib-${__kvar_version}" || return 1
    ./configure --prefix="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    unset -v __kvar_version
    return 0
}

is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

is_root() {
    [ "$(id -u)" -eq 0 ]
}

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]
then
    XDG_DATA_HOME="${XDG_DATA_HOME:-}"
    if [ -z "$XDG_DATA_HOME" ]
    then
        XDG_DATA_HOME="${HOME:?}/.local/share"
    fi
    PREFIX="${XDG_DATA_HOME}/koopa-bootstrap"
fi
PATH="${PREFIX}/bin:/usr/bin:/bin"
CPU_COUNT="$(cpu_count)"
export CPU_COUNT PATH PREFIX

main() {
    printf 'Installing koopa bootstrap in %s.\n' "$PREFIX"
    printf 'This will install openssl3, zlib, bash, python and coreutils.\n'
    rm -fr "$PREFIX"
    mkdir -p "$PREFIX"
    (
        # > set -x
        export CPPFLAGS="-I${PREFIX:?}/include"
        export LDFLAGS="-L${PREFIX:?}/lib -Wl,-rpath,${PREFIX:?}/lib"
        export LIBRARY_PATH="${PREFIX:?}/lib:/usr/lib"
        export PKG_CONFIG_PATH="${PREFIX:?}/lib/pkgconfig"
        # > declare -x | sort
        install_openssl
        install_zlib
        install_bash
        install_python
        install_coreutils
    )
    rm -fr "${PREFIX}/src"
    printf 'Bootstrap installation was successful.\n'
    return 0
}

main "$@"
