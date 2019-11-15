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

name="python"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/python3"

_acid_message "Installing ${name} ${version}."

if [[ -d "${HOME}/.virtualenvs" ]]
then
    _acid_note "Removing existing virtual environments."
    rm -frv "${HOME}/.virtualenvs"
fi

(
    rm -frv "$prefix"
    rm -frv "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="Python-${version}.tar.xz"
    url="https://www.python.org/ftp/python/${version}/${file}"
    _acid_download "$url"
    _acid_extract "$file"
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

_acid_link_cellar "$name" "$version"

_acid_message "Installing pip."
script="get-pip.py"
_acid_download "https://bootstrap.pypa.io/${script}"
"$exe_file" "$script" --no-warn-script-location
rm "$script"

_acid_link_cellar "$name" "$version"

build_prefix="$(_acid_build_prefix)"
_acid_message "Symlinking 'python3' to 'python' in '${build_prefix}'."
ln -fnsv "${build_prefix}/bin/python3" "${build_prefix}/bin/python"

command -v "$exe_file"
"$exe_file" --version

cat << EOF
Python installation was successful.

Reinstall cellar vim, which depends on Python.
Reinstall virtual environments, which have been removed.
EOF
