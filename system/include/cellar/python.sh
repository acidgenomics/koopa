#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

# Python 3.8.0 is failing to compile on RHEL 7.
# generate-posix-vars failed

# Yeah I think this is freaking out if conda or virtualenv are activated.
# Even when you deactivate, the session isn't clean.

# Either that or running make with multicore is erroring, can't tell yet.

# Could not import runpy module

# Consider setting CPPFLAGS and LDFLAGS.
# OpenSSL related issue?
# Ensure we're not activating miniconda or virtualenv upon login.

# > CPPFLAGS="\
# >     -I/opt/X11/include \
# >     -I/usr/local/opt/zlib/include \
# >     -I/usr/local/opt/sqlite3/include \
# >     -I/usr/local/opt/openssl/include \
# > "
# > LDFLAGS="\
# >     -L/opt/X11/lib \
# >     -L/usr/local/lib \
# >     -L/usr/local/opt/openssl/lib \
# > "

# Consider disabling '--enable-optimizations' flag.
# Note that '--with-lto' flag doesn't work with old versions of GCC.

# See also:
# - https://bugs.python.org/issue33374
# - https://github.com/pyenv/pyenv/issues/1388



# Variables                                                                 {{{1
# ==============================================================================

name="python"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/python3"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install Python.

$(_koopa_help_args)

see also:
    - https://www.python.org/

note:
    Bash script.
    Updated 2019-10-16.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    wget "$url"
    tar xfv "Python-${version}.tar.xz"
    cd "Python-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --enable-optimizations \
        --enable-shared \
        --without-ensurepip
    make --jobs="$CPU_COUNT"
    make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

build_prefix="$(_koopa_build_prefix)"
printf "Symlinking 'python3' to 'python' in '%s'.\n" "$build_prefix"
ln -fnsv "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version
