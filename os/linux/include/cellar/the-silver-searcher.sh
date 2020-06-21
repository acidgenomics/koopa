#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Note that Ag has been renamed to The Silver Searcher.
#
# GPG signed releases:
# https://geoff.greer.fm/ag/
#
# GitHub release.
# > file="${version}.tar.gz"
# > url="https://github.com/ggreer/the_silver_searcher/archive/${file}"
# """

# GPG signed release.
name2="the_silver_searcher"
file="${name2}-${version}.tar.gz"
url="https://geoff.greer.fm/ag/releases/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name2}-${version}" || exit 1
./configure --prefix="$prefix"
make --jobs="$jobs"
make install
