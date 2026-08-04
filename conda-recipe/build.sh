#!/bin/sh
set -eu

# Install the pure-Python package.
"${PYTHON}" -m pip install . --no-deps --no-build-isolation --no-cache-dir -vvv

# Copy data files that koopa.prefix.data_prefix() falls back to reading from
# sys.prefix when no git-checkout tree (etc/koopa/app.json alongside the
# repo root) is present -- see prefix.py, this change. setuptools cannot
# package these as package-data because they live outside the koopa/
# package directory.
mkdir -p "${PREFIX}/etc/koopa"
cp etc/koopa/app.json "${PREFIX}/etc/koopa/app.json"
mkdir -p "${PREFIX}/share"
cp -R share/. "${PREFIX}/share/"
