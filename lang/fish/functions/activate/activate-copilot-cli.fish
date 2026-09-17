function _koopa_activate_copilot_cli
    test -x "$KOOPA_PREFIX/bin/copilot"; or return 0
    set -gx COPILOT_AUTO_UPDATE false
end
