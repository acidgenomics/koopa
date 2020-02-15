# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
if [ -f "${XDG_CONFIG_HOME}/koopa/activate" ]
then
    . "${XDG_CONFIG_HOME}/koopa/activate"
fi

