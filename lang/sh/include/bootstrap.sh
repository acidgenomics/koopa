#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2026-05-03.
# """

set -o errexit
set -o nounset
set -o xtrace

is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

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
    rm -fr "${DESTDIR}${PREFIX}/src/${__kvar_name}"
    mkdir -p "${DESTDIR}${PREFIX}/src/${__kvar_name}"
    cd "${DESTDIR}${PREFIX}/src/${__kvar_name}" || return 1
    curl \
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
        'no-docs' \
        'no-legacy' \
        'no-tests' \
        'no-zlib' \
        'shared'
    make VERBOSE=1 --jobs=1 depend
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install_sw DESTDIR="$DESTDIR"
    [ -x "${DESTDIR}${PREFIX}/bin/openssl" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python() {
    __kvar_version='3.12.10'
    printf 'Installing python.\n'
    # On macOS, dylib install_names are baked in as absolute paths at build
    # time. Symlink PREFIX/lib -> staged lib so they resolve during build and
    # integrity checks. Not needed on Linux where LD_LIBRARY_PATH suffices.
    __kvar_remove_lib_symlink=0
    if is_macos && [ -n "$DESTDIR" ] && [ ! -d "${PREFIX}/lib" ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo mkdir -p "$PREFIX"
            sudo ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        else
            mkdir -p "$PREFIX"
            ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        fi
        __kvar_remove_lib_symlink=1
    fi
    download_and_extract \
        'python' \
        "https://www.python.org/ftp/python/${__kvar_version}/Python-${__kvar_version}.tgz" \
        "Python-${__kvar_version}" \
        || return 1
    export LDLIBS='-lcrypto -lssl -lz'
    ./configure \
        --disable-test-modules \
        --prefix="$PREFIX" \
        --with-openssl="${DESTDIR}${PREFIX}"
    make VERBOSE=1 --jobs="${CPU_COUNT:?}"
    make install DESTDIR="$DESTDIR"
    unset -v LDLIBS
    [ -x "${DESTDIR}${PREFIX}/bin/python3" ] || return 1
    printf 'Checking python module integrity.\n'
    LD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
        PYTHONHOME="${DESTDIR}${PREFIX}" \
        "${DESTDIR}${PREFIX}/bin/python3" -c 'import hashlib'
    LD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
        PYTHONHOME="${DESTDIR}${PREFIX}" \
        "${DESTDIR}${PREFIX}/bin/python3" -c 'import ssl'
    LD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
        PYTHONHOME="${DESTDIR}${PREFIX}" \
        "${DESTDIR}${PREFIX}/bin/python3" -c 'import zlib'
    if [ "$__kvar_remove_lib_symlink" -eq 1 ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo rm -f "${PREFIX}/lib"
            sudo rmdir "$PREFIX" 2>/dev/null || true
        else
            rm -f "${PREFIX}/lib"
            rmdir "$PREFIX" 2>/dev/null || true
        fi
    fi
    unset -v __kvar_remove_lib_symlink
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
    make install DESTDIR="$DESTDIR"
    [ -f "${DESTDIR}${PREFIX}/lib/libz.a" ] || return 1
    unset -v __kvar_version
    return 0
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BOOTSTRAP_VERSION="$(cat "${SCRIPT_DIR}/bootstrap-version.txt")"

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]
then
    PREFIX="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
    PREFIX="${PREFIX%/}-bootstrap"
fi
PATH="${PREFIX}/bin:/usr/bin:/bin"
CPU_COUNT="$(cpu_count)"
DESTDIR=''
export CPU_COUNT DESTDIR PATH PREFIX

main() {
    printf 'Installing koopa bootstrap in %s.\n' "$PREFIX"
    printf 'This will install openssl3, zlib, and python.\n'
    __kvar_prefix_parent="$(dirname "$PREFIX")"
    if [ -w "$__kvar_prefix_parent" ]
    then
        __kvar_destdir="${PREFIX}.staging.$$"
        __kvar_use_sudo=0
    else
        __kvar_destdir="$(mktemp -d -t koopa-bootstrap-XXXXXX)"
        __kvar_use_sudo=1
    fi
    unset -v __kvar_prefix_parent
    rm -fr "$__kvar_destdir"
    if ! (
        DESTDIR="$__kvar_destdir"
        export DESTDIR
        __kvar_staged="${DESTDIR}${PREFIX}"
        mkdir -p "$__kvar_staged"
        export CPPFLAGS="-I${__kvar_staged:?}/include"
        export LDFLAGS="-L${__kvar_staged:?}/lib -Wl,-rpath,${PREFIX:?}/lib"
        export LIBRARY_PATH="${__kvar_staged:?}/lib:/usr/lib"
        export PKG_CONFIG_PATH="${__kvar_staged:?}/lib/pkgconfig"
        install_openssl
        install_zlib
        install_python
    )
    then
        printf 'Bootstrap build failed.\n' >&2
        rm -fr "$__kvar_destdir"
        unset -v __kvar_destdir __kvar_use_sudo
        return 1
    fi
    __kvar_staged="${__kvar_destdir}${PREFIX}"
    rm -fr "${__kvar_staged}/src"
    if [ -d "$PREFIX" ]
    then
        rm -fr "${PREFIX}.old"
        if [ "$__kvar_use_sudo" -eq 1 ]
        then
            sudo mv "$PREFIX" "${PREFIX}.old"
        else
            mv "$PREFIX" "${PREFIX}.old"
        fi
    fi
    if [ "$__kvar_use_sudo" -eq 1 ]
    then
        sudo mkdir -p "$(dirname "$PREFIX")"
        sudo mv "$__kvar_staged" "$PREFIX"
        sudo chown -R "$(id -u):$(id -g)" "$PREFIX"
        sudo rm -fr "${PREFIX}.old" "$__kvar_destdir"
    else
        mv "$__kvar_staged" "$PREFIX"
        rm -fr "${PREFIX}.old" "$__kvar_destdir"
    fi
    printf '%s\n' "${BOOTSTRAP_VERSION:?}" > "${PREFIX}/VERSION"
    printf 'Bootstrap version %s installed successfully.\n' "$BOOTSTRAP_VERSION"
    unset -v __kvar_destdir __kvar_use_sudo
    return 0
}

main "$@"
