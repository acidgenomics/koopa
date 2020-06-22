#!/usr/bin/env bash
# shellcheck disable=SC2154

_koopa_mkdir "$prefix"
git clone \
    "https://github.com/sstephenson/rbenv.git" \
    "$prefix"

_koopa_mkdir "${prefix}/plugins"
git clone \
    "https://github.com/sstephenson/ruby-build.git" \
    "${prefix}/plugins/ruby-build"
