function _koopa_activate_antigravity_cli
    # Disable the agy background auto-updater. agy accepts 'true', not '1'.
    set -gx AGY_CLI_DISABLE_AUTO_UPDATE true
end
