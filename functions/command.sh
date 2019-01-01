#!/usr/bin/env bash

quiet_command() {
    command -v "$1" 2>/dev/null
}

# Interchangeable:
# >/dev/null 2>&1  (POSIX)
# &>/dev/null      (bash)
quiet_which() {
    command -v "$1" &>/dev/null
}

require() {
    bin="$1"
    quiet_which "$bin" || { echo >&2 "${bin} missing."; exit 1; }
}
