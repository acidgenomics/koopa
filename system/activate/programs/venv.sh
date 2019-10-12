#!/bin/sh

# Activate Python default virtual environment.
# Updated 2019-10-12.

# Note that we're using this instead of conda as our default interactive
# Python environment, so we can easily use pip.

# Here's how to write a function to detect virtual environment name:
# https://stackoverflow.com/questions/10406926

# Only attempt to autoload for bash or zsh.
_koopa_shell | grep -Eq "^(bash|zsh)$" || return 0

env_name="base"

[ -z "${PYTHON_EXE:-}" ] && \
    [ -f "${HOME}/.virtualenvs/${env_name}/bin/python" ] && \
    PYTHON_EXE="${HOME}/.virtualenvs/${env_name}/bin/python"

# Early return if we don't detect an installation.
if [ -z "${PYTHON_EXE:-}" ]
then
    unset -v env_name
    return 0
fi

export PYTHON_EXE

# Now we're ready to activate.
virtualenv_bin_dir="$(dirname "$PYTHON_EXE")"

# Avoid PATH duplication when spawning inside tmux.
if ! echo "$PATH" | grep -q "$virtualenv_bin_dir"
then
    # shellcheck source=/dev/null
    . "${virtualenv_bin_dir}/activate"
fi

unset -v env_name virtualenv_bin_dir
