#!/usr/bin/env bash
# 
# """
# Ag has been renamed to The Silver Searcher.
#
# Current tagged release hasn't been updated in a while and has a lot of bug
# fixes on GitHub, including GCC 10 support, which is required for Fedora 32.
#
# GPG signed releases:
# > file="${name2}-${version}.tar.gz"
# > url="https://geoff.greer.fm/ag/releases/${file}"
#
# Tagged GitHub release.
# > file="${version}.tar.gz"
# > url="https://github.com/ggreer/${name2}/archive/${file}"
#
# Note that Fedora has changed pkg-config to pkgconf, which is causing issues
# with ag building from source. Install the regular pkg-config from source to
# fix this build issue.
# https://fedoraproject.org/wiki/Changes/
#     pkgconf_as_system_pkg-config_implementation
# In this case, you'll see this error:
# # ./configure: [...] syntax error near unexpected token `PCRE,'
# # ./configure: [...] `PKG_CHECK_MODULES(PCRE, libpcre)'
# https://github.com/ggreer/the_silver_searcher/issues/341
# """

koopa::assert_is_installed pcre-config
# Temporarily installing from master branch, which has bug fixes that aren't
# yet available in tagged release, especially for GCC 10.
version='master'
name2="$(koopa::snake_case_simple "$name")"
file="${version}.tar.gz"
url="https://github.com/ggreer/${name2}/archive/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name2}-${version}"
# Refer to 'build.sh' script for details.
./autogen.sh
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
