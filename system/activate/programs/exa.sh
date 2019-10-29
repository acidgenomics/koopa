# Use exa instead of ls, if installed.
# It has better color support.
# See also: https://the.exa.website/
if _koopa_is_installed exa
then
    alias ls="exa -Fg"
fi
