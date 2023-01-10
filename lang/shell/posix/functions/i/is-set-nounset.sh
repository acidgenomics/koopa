#!/bin/sh

koopa_is_set_nounset() {
    # """
    # Is shell running in 'nounset' variable mode?
    # @note Updated 2020-04-29.
    #
    # Many activation scripts, including Perlbrew and others have unset
    # variables that can cause the shell session to exit.
    #
    # How to enable:
    # > set -o nounset  # -u
    #
    # Bash:
    # shopt -o (arg?)
    # Enabled: 'nounset [...] on'.
    #
    # shopt -op (arg?)
    # Enabled: 'set -o nounset'.
    #
    # Zsh:
    # setopt
    # Enabled: 'nounset'.
    # """
    koopa_str_detect_posix "$(set +o)" 'set -o nounset'
}
