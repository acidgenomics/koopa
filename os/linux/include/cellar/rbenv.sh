#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::mkdir "$prefix"
git clone \
    "https://github.com/sstephenson/rbenv.git" \
    "$prefix"

koopa::mkdir "${prefix}/plugins"
git clone \
    "https://github.com/sstephenson/ruby-build.git" \
    "${prefix}/plugins/ruby-build"
