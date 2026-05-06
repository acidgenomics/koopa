#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2026-05-06.
# """

set -o errexit
set -o nounset
KOOPA_VERBOSE="${KOOPA_VERBOSE:-0}"
if [ "$KOOPA_VERBOSE" -eq 1 ] 2>/dev/null
then
    set -o xtrace
    _make_verbose='VERBOSE=1'
    _curl_verbose='--verbose'
else
    _make_verbose=''
    _curl_verbose='--silent'
fi

is_macos() {
    [ "$(uname -s)" = 'Darwin' ]
}

is_amd64() {
    [ "$(uname -m)" = 'x86_64' ]
}

is_arm64() {
    case "$(uname -m)" in
        'aarch64' | 'arm64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

has_firewall() {
    __kvar_ssl_cert="${SSL_CERT_FILE:-}"
    if [ -z "$__kvar_ssl_cert" ]
    then
        unset -v __kvar_ssl_cert
        return 1
    fi
    case "$__kvar_ssl_cert" in
        "${KOOPA_PREFIX}/"*)
            unset -v __kvar_ssl_cert
            return 1
            ;;
    esac
    unset -v __kvar_ssl_cert
    return 0
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

download_with_fallback() {
    # usage: download_with_fallback <name> <dirname> <url> [url...]
    # Tries each URL in order. Validates each with 'tar -tf' before extracting.
    __dwf_name="${1:?}"
    shift 1
    __dwf_dirname="${1:?}"
    shift 1
    __dwf_src_dir="${DESTDIR}${PREFIX}/src/${__dwf_name}"
    rm -fr "$__dwf_src_dir"
    mkdir -p "$__dwf_src_dir"
    __dwf_ok=0
    for __dwf_url in "$@"
    do
        printf 'Trying %s.\n' "$__dwf_url"
        if curl \
            --fail \
            --location \
            --max-time 300 \
            ${_curl_verbose:+"$_curl_verbose"} \
            "$__dwf_url" \
            -o "${__dwf_src_dir}/src.archive" \
            && tar -tf "${__dwf_src_dir}/src.archive" > /dev/null 2>&1
        then
            __dwf_ok=1
            break
        else
            printf 'Download failed or archive is incomplete, trying next source.\n'
            rm -f "${__dwf_src_dir}/src.archive"
        fi
    done
    if [ "$__dwf_ok" -eq 0 ]
    then
        printf 'All download sources failed for %s.\n' "$__dwf_name" >&2
        unset -v __dwf_dirname __dwf_name __dwf_ok __dwf_src_dir __dwf_url
        return 1
    fi
    cd "$__dwf_src_dir" || return 1
    tar -xf 'src.archive'
    cd "$__dwf_dirname" || return 1
    unset -v __dwf_dirname __dwf_name __dwf_ok __dwf_src_dir __dwf_url
    return 0
}

install_openssl() {
    __kvar_version='3.6.2'
    printf 'Installing openssl.\n'
    __kvar_filename="openssl-${__kvar_version}.tar.gz"
    download_with_fallback \
        'openssl' \
        "openssl-${__kvar_version}" \
        "https://github.com/openssl/openssl/releases/download/openssl-${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/openssl/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
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
    make ${_make_verbose:+"$_make_verbose"} --jobs=1 depend
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}"
    make install_sw DESTDIR="$DESTDIR"
    [ -x "${DESTDIR}${PREFIX}/bin/openssl" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python() {
    __kvar_version='3.12.13'
    printf 'Installing python.\n'
    # On macOS, dylib install_names are baked in as absolute paths at build
    # time. Symlink PREFIX/lib -> staged lib so they resolve during build and
    # integrity checks. Not needed on Linux where LD_LIBRARY_PATH suffices.
    __kvar_remove_lib_symlink=0
    if is_macos && [ -n "$DESTDIR" ] && [ ! -d "${PREFIX}/lib" ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo /bin/mkdir -p "$PREFIX"
            sudo /bin/ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        else
            mkdir -p "$PREFIX"
            ln -snf "${DESTDIR}${PREFIX}/lib" "${PREFIX}/lib"
        fi
        __kvar_remove_lib_symlink=1
    fi
    __kvar_filename="Python-${__kvar_version}.tar.xz"
    download_with_fallback \
        'python' \
        "Python-${__kvar_version}" \
        "https://www.python.org/ftp/python/${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/python/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    export LIBLZMA_CFLAGS="-I${DESTDIR}${PREFIX}/include"
    export LIBLZMA_LIBS="-L${DESTDIR}${PREFIX}/lib -llzma"
    export LDLIBS='-lbz2 -lcrypto -llzma -lssl -lz'
    ./configure \
        --disable-test-modules \
        --prefix="$PREFIX" \
        --with-openssl="${DESTDIR}${PREFIX}"
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}"
    make install DESTDIR="$DESTDIR"
    unset -v LDLIBS LIBLZMA_CFLAGS LIBLZMA_LIBS
    [ -x "${DESTDIR}${PREFIX}/bin/python3" ] || return 1
    printf 'Checking python module integrity.\n'
    if is_macos
    then
        DYLD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
            PYTHONHOME="${DESTDIR}${PREFIX}" \
            "${DESTDIR}${PREFIX}/bin/python3" -c 'import bz2, hashlib, lzma, ssl, zlib'
    else
        LD_LIBRARY_PATH="${DESTDIR}${PREFIX}/lib" \
            PYTHONHOME="${DESTDIR}${PREFIX}" \
            "${DESTDIR}${PREFIX}/bin/python3" -c 'import bz2, hashlib, lzma, ssl, zlib'
    fi
    if [ "$__kvar_remove_lib_symlink" -eq 1 ]
    then
        if [ "${__kvar_use_sudo:-0}" -eq 1 ]
        then
            sudo /bin/rm -f "${PREFIX}/lib"
            sudo /bin/rmdir "$PREFIX" 2>/dev/null || true
        else
            rm -f "${PREFIX}/lib"
            rmdir "$PREFIX" 2>/dev/null || true
        fi
    fi
    unset -v __kvar_remove_lib_symlink
    unset -v __kvar_version
    return 0
}

install_bzip2() {
    __kvar_version='1.0.8'
    printf 'Installing bzip2.\n'
    __kvar_filename="bzip2-${__kvar_version}.tar.gz"
    download_with_fallback \
        'bzip2' \
        "bzip2-${__kvar_version}" \
        "https://sourceware.org/pub/bzip2/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/bzip2/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    make \
        CFLAGS='-fPIC -Wall -Winline -O2 -g -D_FILE_OFFSET_BITS=64' \
        ${_make_verbose:+"$_make_verbose"} \
        --jobs="${CPU_COUNT:?}" \
        PREFIX="${DESTDIR}${PREFIX}" \
        install
    [ -f "${DESTDIR}${PREFIX}/lib/libbz2.a" ] || return 1
    [ -f "${DESTDIR}${PREFIX}/include/bzlib.h" ] || return 1
    unset -v __kvar_version
    return 0
}

install_xz() {
    __kvar_version='5.8.3'
    printf 'Installing xz.\n'
    __kvar_filename="xz-${__kvar_version}.tar.gz"
    download_with_fallback \
        'xz' \
        "xz-${__kvar_version}" \
        "https://github.com/tukaani-project/xz/releases/download/v${__kvar_version}/${__kvar_filename}" \
        "https://koopa.acidgenomics.com/src/xz/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./configure \
        --disable-dependency-tracking \
        --disable-docs \
        --disable-nls \
        --prefix="$PREFIX"
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}"
    make install DESTDIR="$DESTDIR"
    [ -f "${DESTDIR}${PREFIX}/lib/liblzma.a" ] || return 1
    unset -v __kvar_version
    return 0
}

install_zlib() {
    __kvar_version='1.3.2'
    printf 'Installing zlib.\n'
    __kvar_filename="zlib-${__kvar_version}.tar.gz"
    download_with_fallback \
        'zlib' \
        "zlib-${__kvar_version}" \
        "https://koopa.acidgenomics.com/src/zlib/${__kvar_filename}" \
        "https://www.zlib.net/${__kvar_filename}" \
        || return 1
    unset -v __kvar_filename
    ./configure --prefix="$PREFIX"
    make ${_make_verbose:+"$_make_verbose"} --jobs="${CPU_COUNT:?}"
    make install DESTDIR="$DESTDIR"
    [ -f "${DESTDIR}${PREFIX}/lib/libz.a" ] || return 1
    unset -v __kvar_version
    return 0
}

install_python_uv() {
    __kvar_uv_version='0.11.11'
    __kvar_python_version='3.12.13'
    printf 'Installing python via uv.\n'
    __kvar_tmpdir="$(mktemp -d -t koopa-uv-XXXXXX)"
    if is_macos && is_arm64
    then
        __kvar_platform='aarch64-apple-darwin'
    elif is_arm64
    then
        __kvar_platform='aarch64-unknown-linux-gnu'
    elif is_amd64
    then
        __kvar_platform='x86_64-unknown-linux-gnu'
    else
        printf 'Unsupported platform for uv.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv_version
        return 1
    fi
    __kvar_uv_url="https://github.com/astral-sh/uv/releases/download/${__kvar_uv_version}/uv-${__kvar_platform}.tar.gz"
    printf 'Downloading uv %s.\n' "$__kvar_uv_version"
    if ! curl \
        --fail \
        --location \
        --max-time 60 \
        ${_curl_verbose:+"$_curl_verbose"} \
        "$__kvar_uv_url" \
        -o "${__kvar_tmpdir}/uv.tar.gz"
    then
        printf 'Failed to download uv.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv_url __kvar_uv_version
        return 1
    fi
    tar -xf "${__kvar_tmpdir}/uv.tar.gz" -C "$__kvar_tmpdir"
    __kvar_uv="${__kvar_tmpdir}/uv-${__kvar_platform}/uv"
    if [ ! -x "$__kvar_uv" ]
    then
        printf 'uv binary not found after extraction.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    __kvar_cpython_dir="${__kvar_tmpdir}/cpython"
    printf 'Installing cpython %s via uv.\n' "$__kvar_python_version"
    if ! "$__kvar_uv" python install \
        --install-dir "$__kvar_cpython_dir" \
        --no-bin \
        --no-cache \
        --no-config \
        "$__kvar_python_version"
    then
        printf 'uv python install failed.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    __kvar_cpython_subdir="$(find "$__kvar_cpython_dir" -mindepth 1 -maxdepth 1 -type d | head -1)"
    if [ -z "$__kvar_cpython_subdir" ]
    then
        printf 'No cpython directory found after install.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    __kvar_target="${DESTDIR}${PREFIX}"
    mkdir -p "$__kvar_target"
    cp -R "$__kvar_cpython_subdir"/. "$__kvar_target"/
    if [ ! -x "${__kvar_target}/bin/python3" ]
    then
        printf 'python3 binary not found after copy.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    printf 'Checking python module integrity.\n'
    if ! "${__kvar_target}/bin/python3" -c 'import bz2, hashlib, lzma, ssl, zlib'
    then
        printf 'Python module integrity check failed.\n' >&2
        rm -fr "$__kvar_tmpdir"
        unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
        return 1
    fi
    rm -fr "$__kvar_tmpdir"
    unset -v __kvar_cpython_dir __kvar_cpython_subdir __kvar_platform __kvar_python_version __kvar_target __kvar_tmpdir __kvar_uv __kvar_uv_url __kvar_uv_version
    return 0
}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KOOPA_PREFIX="$SCRIPT_DIR"
BOOTSTRAP_VERSION="$(cat "${KOOPA_PREFIX}/etc/koopa/bootstrap-version.txt")"

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]
then
    PREFIX="${KOOPA_PREFIX}-bootstrap"
fi
PATH="${PREFIX}/bin:/usr/bin:/bin"
CPU_COUNT="$(cpu_count)"
DESTDIR=''
export CPU_COUNT DESTDIR PATH PREFIX

main() {
    if is_macos && is_amd64
    then
        printf 'Error: Intel Mac (x86_64) is no longer supported.\n' >&2
        printf 'koopa requires macOS on Apple Silicon (arm64).\n' >&2
        return 1
    fi
    printf 'Installing koopa bootstrap in %s.\n' "$PREFIX"
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
    __kvar_build_ok=0
    if ! has_firewall
    then
        if (
            DESTDIR="$__kvar_destdir"
            export DESTDIR
            install_python_uv
        )
        then
            __kvar_build_ok=1
        else
            printf 'uv fast path failed, falling back to source build.\n' >&2
            rm -fr "$__kvar_destdir"
            mkdir -p "$__kvar_destdir"
        fi
    fi
    if [ "$__kvar_build_ok" -eq 0 ]
    then
        printf 'Building from source: openssl3, zlib, bzip2, xz, python.\n'
        if ! (
            DESTDIR="$__kvar_destdir"
            export DESTDIR
            __kvar_staged="${DESTDIR}${PREFIX}"
            mkdir -p "$__kvar_staged"
            export CPPFLAGS="-I${__kvar_staged:?}/include"
            export LDFLAGS="-L${__kvar_staged:?}/lib -Wl,-rpath,${PREFIX:?}/lib"
            if ! is_macos
            then
                export LD_LIBRARY_PATH="${__kvar_staged:?}/lib"
            fi
            export LIBRARY_PATH="${__kvar_staged:?}/lib:/usr/lib"
            export PKG_CONFIG_PATH="${__kvar_staged:?}/lib/pkgconfig"
            install_openssl
            install_zlib
            install_bzip2
            install_xz
            install_python
        )
        then
            printf 'Bootstrap build failed.\n' >&2
            rm -fr "$__kvar_destdir"
            unset -v __kvar_build_ok __kvar_destdir __kvar_use_sudo
            return 1
        fi
    fi
    unset -v __kvar_build_ok
    __kvar_staged="${__kvar_destdir}${PREFIX}"
    rm -fr "${__kvar_staged}/src"
    if [ -d "$PREFIX" ]
    then
        if [ "$__kvar_use_sudo" -eq 1 ]
        then
            sudo /bin/rm -fr "${PREFIX}.old"
            sudo /bin/mv "$PREFIX" "${PREFIX}.old"
        else
            rm -fr "${PREFIX}.old"
            mv "$PREFIX" "${PREFIX}.old"
        fi
    elif [ "$__kvar_use_sudo" -eq 1 ]
    then
        sudo /bin/rm -fr "${PREFIX}.old"
    else
        rm -fr "${PREFIX}.old"
    fi
    if [ "$__kvar_use_sudo" -eq 1 ]
    then
        sudo /bin/mkdir -p "$(dirname "$PREFIX")"
        sudo /bin/mv "$__kvar_staged" "$PREFIX"
        sudo /usr/sbin/chown -R "$(id -u):$(id -g)" "$PREFIX"
        sudo /bin/rm -fr "${PREFIX}.old" "$__kvar_destdir"
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
