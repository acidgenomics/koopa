#!/bin/sh

_koopa_macos_activate_vscode() {
    # """
    # Activate macOS VS Code CLI.
    # @note Updated 2026-09-30.
    # """
    _koopa_add_to_path_end \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin'
    return 0
}
