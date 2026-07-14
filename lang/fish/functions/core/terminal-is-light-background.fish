function _koopa_terminal_is_light_background
    # Query terminal background color via OSC 11.
    # @note Updated 2026-05-30.
    isatty stdin; or return 1
    if set -q TMUX; or string match -q 'screen*' -- "$TERM"; or string match -q 'tmux*' -- "$TERM"
        return 1
    end
    test "$TERM_PROGRAM" = vscode; and return 1
    set -l old_settings (stty -g 2>/dev/null); or return 1
    # fish has no trap mechanism for functions, so a hard signal between the
    # stty raw below and the restore two lines later can leave the terminal in
    # raw mode.  The dd timeout (time 2 = 0.2s) bounds the raw window; the
    # early returns after the restore are already post-restore and safe.
    stty raw -echo min 0 time 2 2>/dev/null
    printf '\033]11;?\033\\' > /dev/tty
    set -l response (dd bs=64 count=1 2>/dev/null < /dev/tty)
    stty $old_settings 2>/dev/null
    string match -q '*rgb:*' -- "$response"; or return 1
    set -l rgb (string replace -r '.*rgb:([0-9a-fA-F/]+).*' '$1' -- "$response")
    set -l parts (string split '/' -- "$rgb")
    test (count $parts) -ge 3; or return 1
    set -l r (math "0x"(string sub -l 2 -- $parts[1]))
    set -l g (math "0x"(string sub -l 2 -- $parts[2]))
    set -l b (math "0x"(string sub -l 2 -- $parts[3]))
    set -l luma (math "($r * 299 + $g * 587 + $b * 114) / 1000")
    test "$luma" -gt 128
end
