#!/usr/bin/env bash

# The '--enable-optimizations' flag can boost Python performance by ~10% but
# currently runs into build issues with old compilation chains (e.g. GCC 4),
# which are common on RHEL and other conservative cluster/VM configurations.
# Therefore, we are disabling this flag by default.
#
# Recently, I'm seeing a new 'generate-posix-vars' error pop up with 3.8.0
# installs on RHEL 7 machines.
#
# See also:
# - https://bugs.python.org/issue33374
# - https://github.com/pyenv/pyenv/issues/1388

_koopa_assert_has_no_args "$@"

name="python"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/python3"

_koopa_message "Installing ${name} ${version}."

if [[ -d "${HOME}/.virtualenvs" ]]
then
    _koopa_note "Removing existing virtual environments."
    rm -frv "${HOME}/.virtualenvs"
fi

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "Python-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
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
_koopa_message "Symlinking 'python3' to 'python' in '${build_prefix}'."
ln -fnsv "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version

cat << EOF
Python installation was successful.

Reinstall cellar vim, which depends on Python.
Reinstall virtual environments, which were removed.
EOF
