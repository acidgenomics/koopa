# Disable Copilot CLI startup updates.
export def --env _koopa_activate_copilot_cli [] {
    let copilot = $"($env.KOOPA_PREFIX)/bin/copilot"
    if not ($copilot | path exists) {
        return
    }
    $env.COPILOT_AUTO_UPDATE = "false"
}
