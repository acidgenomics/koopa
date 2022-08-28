#!/bin/sh

# FIXME This doesn't currently support dark / light mode?
# FIXME Does this affect fd colors?
# FIXME This seems to be required for macOS colors...argh.

koopa_macos_activate_cli_colors() {
    # """
    # Activate macOS-specific terminal color settings.
    # @note Updated 2020-07-05.
    #
    # Refer to 'man ls' for 'LSCOLORS' section on color designators. Note that
    # this doesn't get inherited by GNU coreutils, which uses 'LS_COLORS'.
    #
    # @seealso
    # - https://www.cyberciti.biz/faq/
    #     apple-mac-osx-terminal-color-ls-output-option/
    # """
    [ -z "${CLICOLOR:-}" ] && export CLICOLOR=1
    # > [ -z "${LSCOLORS:-}" ] && export LSCOLORS='Gxfxcxdxbxegedabagacad'
    return 0
}
