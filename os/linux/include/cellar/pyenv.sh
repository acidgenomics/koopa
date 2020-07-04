#!/usr/bin/env bash
# shellcheck disable=SC2154

koopa::mkdir "$prefix"
git clone https://github.com/pyenv/pyenv.git "$prefix"

