#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.ruby-lang.org/en/downloads/
# """

# Ensure '2.7.1p83' becomes '2.7.1' here, for example.
version="$(koopa::sanitize_version "$version")"
minor_version="$(koopa::major_minor_version "$version")"
file="${name}-${version}.tar.gz"
url="https://cache.ruby-lang.org/pub/${name}/${minor_version}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
# This will fail on Ubuntu 18 otherwise.
# https://github.com/rbenv/ruby-build/issues/156
# https://github.com/rbenv/ruby-build/issues/729
export RUBY_CONFIGURE_OPTS=--disable-install-doc
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
