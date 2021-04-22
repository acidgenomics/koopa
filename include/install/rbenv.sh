#!/usr/bin/env bash
# 
koopa::mkdir "$prefix"
git clone \
    'https://github.com/sstephenson/rbenv.git' \
    "$prefix"
koopa::mkdir "${prefix}/plugins"
git clone \
    'https://github.com/sstephenson/ruby-build.git' \
    "${prefix}/plugins/ruby-build"
