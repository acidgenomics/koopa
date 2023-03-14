#!/bin/sh

_koopa_activate_lesspipe() {
    # """
    # Activate lesspipe.
    # @note Updated 2023-03-10.
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
    # - Use extended ANSI codes, for Markdown rendering in iTerm2.
    #   https://github.com/wofr06/lesspipe/issues/48
    # """
    __kvar_lesspipe="$(_koopa_bin_prefix)/lesspipe.sh"
    if [ ! -x "$__kvar_lesspipe" ]
    then
        unset -v __kvar_lesspipe
        return 0
    fi
    export LESS='-R'
    export LESSANSIMIDCHARS="0123456789;[?!\"'#%()*+ SetMark"
    export LESSCHARSET='utf-8'
    export LESSCOLOR='yes'
    export LESSOPEN="|${__kvar_lesspipe} %s"
    export LESSQUIET=1
    export LESS_ADVANCED_PREPROCESSOR=1
    unset -v __kvar_lesspipe
    return 0
}
