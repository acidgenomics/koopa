#!/usr/bin/env bash

# FIXME This now successfully prompts on macOS Sequoia but the command errors
# before the install is allowed to proceed.

main() {
    # """
    # Install Xcode CLT.
    # @note Updated 2023-05-01.
    #
    # This currently requires user interaction.
    #
    # @seealso
    # - https://apple.stackexchange.com/questions/93573/
    # - https://download.developer.apple.com/Developer_Tools/
    #   Command_Line_Tools_for_Xcode_13.4/Command_Line_Tools_for_Xcode_13.4.dmg
    # - https://download.developer.apple.com/Developer_Tools/
    #   Command_Line_Tools_for_Xcode_14/Command_Line_Tools_for_Xcode_14.dmg
    #
    # Alternative minimal approach (used previously for Homebrew):
    # > xcode-select --install &>/dev/null || true
    #
    # How to install non-interactively (currently a bit hacky):
    # - https://apple.stackexchange.com/questions/107307/
    # - https://github.com/Homebrew/install/blob/
    #     878b5a18b89ff73f2f221392ecaabd03c1e69c3f/install#L297
    # """
    local -A app dict
    app['xcode_select']="$(koopa_macos_locate_xcode_select)"
    app['xcodebuild']="$(koopa_macos_locate_xcodebuild)"
    koopa_assert_is_executable "${app[@]}"
    dict['prefix']="$("${app['xcode_select']}" -p 2>/dev/null || true)"
    if [[ -d "${dict['prefix']}" ]]
    then
        koopa_alert "Removing previous install at '${dict['prefix']}'."
        koopa_rm --sudo "${dict['prefix']}"
    fi
    # This step will prompt interactively, which is annoying. See above for
    # alternative workarounds that are more complicated, but may improve this.
    "${app['xcode_select']}" --install
    koopa_sudo "${app['xcodebuild']}" -license 'accept'
    koopa_sudo "${app['xcode_select']}" -r
    prefix="$("${app['xcode_select']}" -p)"
    koopa_assert_is_dir "${dict['prefix']}"
    return 0
}
