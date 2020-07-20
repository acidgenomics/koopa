#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# The '--enable-optimizations' flag can boost Python performance by ~10% but
# currently runs into build issues with old compilation chains (e.g. GCC 4),
# which are common on RHEL and other conservative cluster/VM configurations.
# Therefore, we are disabling this flag by default.
#
#
# Multiprocessing tests can fail on very large multi-core VMs due to too many
# open files, so disable tests if necessary.
#
#
# Install libffi if you hit cryptic '_ctypes' module errors.
#
# See also:
# - https://stackoverflow.com/questions/27022373
#
#
# I'm seeing a 'generate-posix-vars' error pop up with 3.8.0 install on RHEL 7.
# 
# See also:
# - https://bugs.python.org/issue33374
# - https://github.com/pyenv/pyenv/issues/1388
#
#
# Ubuntu 18 LTS requires LDFLAGS to be set, otherwise we hit:
# python3: error while loading shared libraries: libpython3.8.so.1.0: cannot
# open shared object file: No such file or directory
#
# This alone works, but I've set other paths, as recommended.
# LDFLAGS="-Wl,-rpath ${prefix}/lib"
#
# Check config with:
# > ldd /usr/local/bin/python3
#
# See also:
# - https://stackoverflow.com/questions/43333207
# """

file="Python-${version}.tar.xz"
url="https://www.python.org/ftp/python/${version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "Python-${version}"
./configure \
    --prefix="$prefix" \
    --enable-shared \
    --without-ensurepip \
    LDFLAGS="-Wl,--rpath=${make_prefix}/lib"
make --jobs="$jobs"
# > make test
make install

# Remove '__pycache__' directories, which can cause rsync issues.
# > koopa::python_remove_pycache "$prefix"

# Symlink 'python3' to 'python'.
if [[ ! -f "${prefix}/bin/python" ]]
then
    koopa::h2 "Symlinking 'python3' to 'python'."
    kooopa::ln "${prefix}/bin/python3" "${prefix}/bin/python"
fi
