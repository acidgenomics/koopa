#!/usr/bin/env fish

# Koopa shell bootloader activation for fish.
# @note Updated 2026-05-01.
#
# Usage:
#     source /path/to/koopa/activate.fish
#
# Add this to your '~/.config/fish/config.fish' file.

if set -q KOOPA_SKIP
    if test "$KOOPA_SKIP" -eq 1
        return 0
    end
end

if not set -q KOOPA_FORCE; or test "$KOOPA_FORCE" -ne 1
    if not status is-interactive
        return 0
    end
end

if set -q KOOPA_PREFIX
    set -gx KOOPA_SUBSHELL 1
end

set -l __kvar_script (status filename)
if test -L "$__kvar_script"
    set __kvar_script (realpath "$__kvar_script")
end
set -gx KOOPA_PREFIX (realpath (dirname "$__kvar_script"))

set -gx KOOPA_ACTIVATE 1

set -l __kvar_header "$KOOPA_PREFIX/lang/fish/include/header.fish"
if test -f "$__kvar_header"
    source "$__kvar_header"
end

set -e KOOPA_ACTIVATE
