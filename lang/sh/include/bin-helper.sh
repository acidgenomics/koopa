#!/bin/sh

# Shared POSIX bootstrap for bin/ scripts that delegate to Python.
# Source this file and call: _koopa_exec_python "$@"

__koopa_bin_realpath() {
    _rp_out="$(readlink -f "$1" 2>/dev/null || true)"
    if [ -z "$_rp_out" ]; then
        _rp_out="$( \
            perl -MCwd -le \
                'print Cwd::abs_path shift' \
                "$1" \
            2>/dev/null \
            || true \
        )"
    fi
    if [ -z "$_rp_out" ]; then
        _rp_out="$( \
            python3 -c \
                "import os; print(os.path.realpath('$1'))" \
            2>/dev/null \
            || true \
        )"
    fi
    [ -n "$_rp_out" ] || return 1
    printf '%s\n' "$_rp_out"
}

_koopa_exec_python() {
    _koopa_bin="$0"
    if [ -L "$_koopa_bin" ]; then
        _koopa_bin="$(__koopa_bin_realpath "$_koopa_bin")"
    fi
    [ -x "$_koopa_bin" ] || return 1
    _koopa_prefix="$(__koopa_bin_realpath "$(dirname "$_koopa_bin")/..")"
    [ -d "$_koopa_prefix" ] || return 1
    _python="${_koopa_prefix}/opt/python3.14/bin/python3.14"
    if [ ! -x "$_python" ]; then
        _python="$(command -v python3.14 2>/dev/null || true)"
        if [ -z "$_python" ]; then
            _python="$(command -v python3 2>/dev/null || true)"
            if [ -n "$_python" ] && \
                ! "$_python" -c \
                    'import sys; sys.exit(0 if sys.version_info >= (3, 14) else 1)' \
                    2>/dev/null
            then
                _python=''
            fi
        fi
    fi
    if [ ! -x "$_python" ]; then
        printf 'Error: Python 3.14+ is required.\n' >&2
        return 1
    fi
    _script_name="$(basename "$_koopa_bin")"
    KOOPA_PREFIX="$_koopa_prefix" \
    PYTHONPATH="${_koopa_prefix}/lang/python/src${PYTHONPATH:+:${PYTHONPATH}}" \
        exec "$_python" -m koopa.cli_bin "$_script_name" "$@"
}
