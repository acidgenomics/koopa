function _koopa_activate_pyright
    # Activate pyright.
    # @note Updated 2026-09-04.
    test -x "$KOOPA_PREFIX/bin/pyright"; or return 0
    set -gx PYRIGHT_PYTHON_IGNORE_WARNINGS 1
end
