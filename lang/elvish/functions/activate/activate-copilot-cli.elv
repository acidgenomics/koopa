# Disable Copilot CLI startup updates.
fn activate-copilot-cli {
    var copilot = $E:KOOPA_PREFIX'/bin/copilot'
    if (not (path:is-regular &follow-symlink $copilot)) {
        return
    }
    set-env COPILOT_AUTO_UPDATE 'false'
}
