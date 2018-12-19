quiet_command() {
    command -v "$1" 2>/dev/null
}

quiet_which() {
    which "$1" &>/dev/null
}
