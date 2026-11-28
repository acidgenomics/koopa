# Disable the Antigravity CLI (agy) background auto-updater.
# agy accepts 'true', not '1'.
export def --env _koopa_activate_antigravity_cli [] {
    $env.AGY_CLI_DISABLE_AUTO_UPDATE = "true"
}
