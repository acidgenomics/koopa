function _koopa_activate_lesspipe
    # Activate lesspipe.
    # @note Updated 2026-06-13.
    set -l lesspipe "$KOOPA_PREFIX/bin/lesspipe.sh"
    if not test -x "$lesspipe"
        return 0
    end
    set -gx LESS '-R'
    set -gx LESSANSIMIDCHARS '0123456789;[?!"\'#%()*+ SetMark'
    set -gx LESSCHARSET 'utf-8'
    set -gx LESSCOLOR 'yes'
    set -gx LESSOPEN "|$lesspipe %s"
    set -gx LESSQUIET 1
    set -gx LESS_ADVANCED_PREPROCESSOR 1
end
