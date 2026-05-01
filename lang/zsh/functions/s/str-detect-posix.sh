#!/usr/bin/env zsh

_koopa_str_detect_posix() {
    [[ "${1#*"$2"}" != "$1" ]]
}
