#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

# # generate-posix-vars failed
# Double check that venv and conda environments unloaded clean, and that
# conda python is not in PATH.

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

printf "Removing existing virtual environments.\n"
rm -frv "${HOME}/.virtualenvs"

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
    # Multiprocessing tests can fail on very large multi-core VMs due to too
    # many open files, so disable tests if necessary.
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

build_prefix="$(_koopa_build_prefix)"
printf "Symlinking 'python3' to 'python' in '%s'.\n" "$build_prefix"
ln -fnsv "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version

cat << EOF
Python installation was successful.

Reinstall cellar vim, which depends on Python.
Reinstall virtual environments, which were removed.
EOF
