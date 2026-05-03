#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2026-05-02.
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
        __kvar_num="$("$__kvar_sysctl" -n 'hw.ncpu')"
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

download_and_extract() {
    __kvar_name="${1:?}"
    __kvar_url="${2:?}"
    __kvar_dirname="${3:?}"
    mkdir -p "${PREFIX}/src/${__kvar_name}"
    cd "${PREFIX}/src/${__kvar_name}" || return 1
    curl \
        --create-dirs \
        --fail \
        --location \
        --retry 5 \
        --show-error \
        --verbose \
        "$__kvar_url" \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd "$__kvar_dirname" || return 1
    unset -v \
        __kvar_dirname \
        __kvar_name \
        __kvar_url
    return 0
}

install_bash() {
    __kvar_version='5.3'
    printf 'Installing bash.\n'
    download_and_extract \
        'bash' \
        "https://ftpmirror.gnu.org/gnu/bash/bash-${__kvar_version}.tar.gz" \
        "bash-${__kvar_version}" \
        || return 1
    ./configure --prefix="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    [ -x "${PREFIX}/bin/bash" ] || return 1
    unset -v __kvar_version
    return 0
}

install_coreutils() {
    __kvar_version='9.11'
    printf 'Installing coreutils.\n'
    download_and_extract \
        'coreutils' \
        "https://ftpmirror.gnu.org/gnu/coreutils/coreutils-${__kvar_version}.tar.gz" \
        "coreutils-${__kvar_version}" \
        || return 1
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
    __kvar_version='3.6.2'
    printf 'Installing openssl.\n'
    download_and_extract \
        'openssl' \
        "https://github.com/openssl/openssl/releases/download/openssl-${__kvar_version}/openssl-${__kvar_version}.tar.gz" \
        "openssl-${__kvar_version}" \
        || return 1
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
    __kvar_version='3.14.4'
    printf 'Installing python.\n'
    download_and_extract \
        'python' \
        "https://www.python.org/ftp/python/${__kvar_version}/Python-${__kvar_version}.tgz" \
        "Python-${__kvar_version}" \
        || return 1
    export LDLIBS='-lcrypto -lssl -lz'
    ./configure \
        --prefix="$PREFIX" \
        --with-openssl="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    unset -v LDLIBS
    [ -x "${PREFIX}/bin/python3" ] || return 1
    printf 'Checking python module integrity.\n'
    "${PREFIX}/bin/python3" -c 'import hashlib'
    "${PREFIX}/bin/python3" -c 'import lzma'
    "${PREFIX}/bin/python3" -c 'import ssl'
    "${PREFIX}/bin/python3" -c 'import zlib'
    unset -v __kvar_version
    return 0
}

install_xz() {
    __kvar_version='5.8.3'
    printf 'Installing xz.\n'
    download_and_extract \
        'xz' \
        "https://github.com/tukaani-project/xz/releases/download/v${__kvar_version}/xz-${__kvar_version}.tar.gz" \
        "xz-${__kvar_version}" \
        || return 1
    ./configure --prefix="$PREFIX" --disable-static
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    [ -x "${PREFIX}/bin/xz" ] || return 1
    unset -v __kvar_version
    return 0
}

install_zlib() {
    __kvar_version='1.3.2'
    printf 'Installing zlib.\n'
    download_and_extract \
        'zlib' \
        "https://www.zlib.net/zlib-${__kvar_version}.tar.gz" \
        "zlib-${__kvar_version}" \
        || return 1
    ./configure --prefix="$PREFIX"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install
    [ -f "${PREFIX}/lib/libz.a" ] || return 1
    unset -v __kvar_version
    return 0
}

is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

is_root() {
    [ "$(id -u)" -eq 0 ]
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOTSTRAP_VERSION="$(cat "${SCRIPT_DIR}/bootstrap-version.txt")"

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
    printf 'This will install openssl3, xz, zlib, bash, python and coreutils.\n'
    # Save old bootstrap so we can restore on failure.
    __kvar_backup="${PREFIX}.backup.$$"
    if [ -d "$PREFIX" ]
    then
        mv "$PREFIX" "$__kvar_backup"
    fi
    mkdir -p "$PREFIX"
    if ! (
        # > set -x
        export CPPFLAGS="-I${PREFIX:?}/include"
        export LDFLAGS="-L${PREFIX:?}/lib -Wl,-rpath,${PREFIX:?}/lib"
        export LIBRARY_PATH="${PREFIX:?}/lib:/usr/lib"
        export PKG_CONFIG_PATH="${PREFIX:?}/lib/pkgconfig"
        # > declare -x | sort
        install_openssl
        install_xz
        install_zlib
        install_bash
        install_python
        install_coreutils
    )
    then
        printf 'Bootstrap build failed. Restoring previous bootstrap.\n' >&2
        rm -fr "$PREFIX"
        if [ -d "$__kvar_backup" ]
        then
            mv "$__kvar_backup" "$PREFIX"
        fi
        unset -v __kvar_backup
        return 1
    fi
    rm -fr "${PREFIX}/src"
    rm -fr "$__kvar_backup"
    printf '%s\n' "${BOOTSTRAP_VERSION:?}" > "${PREFIX}/VERSION"
    printf 'Bootstrap version %s installed successfully.\n' "$BOOTSTRAP_VERSION"
    unset -v __kvar_backup
    return 0
}

main "$@"
