#!/usr/bin/env zsh

# Configure lesspipe.
# Updated 2019-10-28.
#
# Preconfigured on some Linux systems at '/etc/profile.d/less.sh'.
#
# See also:
# - https://github.com/wofr06/lesspipe

[ -n "${LESSOPEN:-}" ] && return 0

if _koopa_is_installed "lesspipe.sh"
then
    lesspipe_exe="$(_koopa_realpath "lesspipe.sh")"
    export LESSOPEN="|${lesspipe_exe} %s"
    export LESS_ADVANCED_PREPROCESSOR=1
fi
