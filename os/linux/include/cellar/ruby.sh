#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.ruby-lang.org/en/downloads/
# """

# Ensure '2.6.5p' becomes '2.6.5' here, for example.
version="$(_koopa_sanitize_version "$version")"
minor_version="$(_koopa_major_minor_version "$version")"
file="${name}-${version}.tar.gz"
url="https://cache.ruby-lang.org/pub/${name}/${minor_version}/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
# This will fail on Ubuntu 18 otherwise.
# https://github.com/rbenv/ruby-build/issues/156
# https://github.com/rbenv/ruby-build/issues/729
export RUBY_CONFIGURE_OPTS=--disable-install-doc
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
