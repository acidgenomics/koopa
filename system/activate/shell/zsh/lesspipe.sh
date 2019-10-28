#!/usr/bin/env zsh

# Configure lesspipe.
# Updated 2019-10-28.

# See also:
# - https://github.com/wofr06/lesspipe

if _koopa_is_installed "lesspipe.sh"
then
    export LESSOPEN="|/usr/local/bin/lesspipe.sh %s"
    export LESS_ADVANCED_PREPROCESSOR=1
fi
