function _koopa_activate_pyright
    # Activate pyright.
    # @note Updated 2026-06-13.
    test -x "$KOOPA_PREFIX/bin/pyright"; or return 0
    set -gx PYRIGHT_PYTHON_FORCE_VERSION latest
end
