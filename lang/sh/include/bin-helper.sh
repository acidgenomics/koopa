#!/bin/sh

# Shared POSIX bootstrap for bin/ scripts that delegate to Python.
# Source this file and call:
#   _koopa_exec_main "$@"   (for bin/koopa -> koopa.cli_main)
#   _koopa_exec_python "$@" (for other bin scripts -> koopa.cli_bin)

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

__koopa_resolve_prefix() {
    _koopa_bin="$0"
    if [ -L "$_koopa_bin" ]; then
        _koopa_bin="$(__koopa_bin_realpath "$_koopa_bin")"
    fi
    [ -x "$_koopa_bin" ] || return 1
    __koopa_bin_realpath "$(dirname "$_koopa_bin")/.."
}

__koopa_check_python() {
    [ -x "$1" ] && "$1" -c "import lzma, subprocess" 2>/dev/null
}

__koopa_find_python() {
    _koopa_prefix="$1"
    _venv_python="${_koopa_prefix}/.venv/bin/python3"
    if __koopa_check_python "$_venv_python"; then
        printf '%s\n' "$_venv_python"
        return 0
    fi
    _python="${_koopa_prefix}/opt/python3.14/bin/python3.14"
    if __koopa_check_python "$_python"; then
        printf '%s\n' "$_python"
        return 0
    fi
    _python="$(command -v python3.14 2>/dev/null || true)"
    if [ -n "$_python" ] && __koopa_check_python "$_python"; then
        printf '%s\n' "$_python"
        return 0
    fi
    _python="$(command -v python3 2>/dev/null || true)"
    if [ -n "$_python" ] && \
        "$_python" -c \
            'import sys; sys.exit(0 if sys.version_info >= (3, 14) else 1)' \
            2>/dev/null && \
        __koopa_check_python "$_python"
    then
        printf '%s\n' "$_python"
        return 0
    fi
    return 1
}

__koopa_exec_module() {
    _module="$1"
    shift
    _koopa_prefix="$(__koopa_resolve_prefix)" || return 1
    [ -d "$_koopa_prefix" ] || return 1
    _python="$(__koopa_find_python "$_koopa_prefix")" || {
        _bootstrap="${_koopa_prefix}/etc/koopa/bootstrap.sh"
        printf '%s\n' \
            'Error: Python 3.14+ is required but not found.' \
            '' \
            'To bootstrap Python and core dependencies from source, run:' \
            "  sh '${_bootstrap}'" \
            '' \
            'Then retry your command.' \
            >&2
        return 1
    }
    export KOOPA_PREFIX="$_koopa_prefix"
    case "$_python" in
        */.venv/*)
            exec "$_python" -m "$_module" "$@"
            ;;
        *)
            PYTHONPATH="${_koopa_prefix}/lang/python/src${PYTHONPATH:+:${PYTHONPATH}}" \
                exec "$_python" -m "$_module" "$@"
            ;;
    esac
}

_koopa_exec_main() {
    __koopa_exec_module koopa.cli_main "$@"
}

_koopa_exec_python() {
    _script_name="$(basename "$0")"
    if [ -L "$0" ]; then
        _script_name="$(basename "$(__koopa_bin_realpath "$0")")"
    fi
    __koopa_exec_module koopa.cli_bin "$_script_name" "$@"
}
