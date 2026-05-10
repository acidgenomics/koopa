#!/usr/bin/env bash

_koopa_str_detect_posix() {
    [[ "${1#*"$2"}" != "$1" ]]
}
