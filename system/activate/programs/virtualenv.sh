#!/bin/sh
# shellcheck disable=SC2236

# Activate Python "default" virtual environment.
# Modified 2019-06-18.

# Note that we're using this instead of conda as our default interactive
# Python environment, so we can easily use pip.



# Only attempt to autoload for bash or zsh.
[ "$KOOPA_SHELL" != "bash" ] && \
    [ "$KOOPA_SHELL" != "zsh" ] && \
    return

python_env="default"

[ -z "${PYTHON_EXE:-}" ] && \
    [ -f "${HOME}/.virtualenvs/${python_env}/bin/python" ] && \
    PYTHON_EXE="${HOME}/.virtualenvs/${python_env}/bin/python"

# Early return if we don't detect an installation.
[ -z "${PYTHON_EXE:-}" ] && return 0
export PYTHON_EXE

# Don't allow Python to change the prompt string.
export VIRTUAL_ENV_DISABLE_PROMPT=1

# Now we're ready to activate.
virtualenv_bin_dir="$(dirname "$PYTHON_EXE")"

# Avoid virtualenv PATH duplicate when spawning inside tmux.
if ! echo "$PATH" | grep -q "$virtualenv_bin_dir"
then
    # shellcheck source=/dev/null
    . "${virtualenv_bin_dir}/activate"
fi

unset -v python_env virtualenv_bin_dir
