#!/bin/sh

koopa_activate_lesspipe() {
    # """
    # Activate lesspipe.
    # @note Updated 2022-05-12.
    #
    # Preferentially uses 'bat' when installed.
    #
    # @seealso
    # - man lesspipe
    # - https://github.com/wofr06/lesspipe/
    # - https://manned.org/lesspipe/
    # - https://superuser.com/questions/117841/
    # - brew info lesspipe
    # - To list available styles (requires pygments):
    #   'pygmentize -L styles'
    # """
    local lesspipe
    lesspipe="$(koopa_bin_prefix)/lesspipe.sh"
    [ -x "$lesspipe" ] || return 0
    export LESS='-R'
    export LESSCOLOR='yes'
    export LESSOPEN="|${lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    # Use extended ANSI codes, for Markdown rendering in iTerm2.
    # https://github.com/wofr06/lesspipe/issues/48
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    [ -z "${LESSCHARSET:-}" ] && export LESSCHARSET='utf-8'
    return 0
}
