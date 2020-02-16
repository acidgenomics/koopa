#!/bin/sh



# Pre-flight checks  {{{1
# ==============================================================================

# Operating system  {{{2
# ------------------------------------------------------------------------------

# Bash sets the shell variable OSTYPE (e.g. linux-gnu).
# However, this doesn't work consistently with zsh, so use uname instead.

case "$(uname -s)" in
    Darwin)
        ;;
    Linux)
        ;;
    *)
        _koopa_stop "Unsupported operating system."
esac

# Bad settings  {{{2
# ------------------------------------------------------------------------------

# Note that we're skipping this checks inside RStudio shell.
if [ -z "${RSTUDIO:-}" ]
then
    _koopa_warn_if_export JAVA_HOME LD_LIBRARY_PATH PYTHONHOME R_HOME
fi



# Standard globals  {{{1
# ==============================================================================

# This variables are used by some koopa scripts, so ensure they're always
# consistently exported across platforms.

# HOSTNAME
if [ -z "${HOSTNAME:-}" ]
then
    HOSTNAME="$(uname -n)"
    export HOSTNAME
fi

# OSTYPE
# Automatically set by bash and zsh.
if [ -z "${OSTYPE:-}" ]
then
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    export OSTYPE
fi

# SHELL
# Note that this doesn't currently get set by RStudio terminal.
SHELL="$(_koopa_which_realpath "$KOOPA_SHELL")"
export SHELL

# TERM
# Terminal color mode.
# This should normally be set by the terminal client.
if [ -z "${TERM:-}" ]
then
    export TERM="xterm-256color"
fi

# TMPDIR
if [ -z "${TMPDIR:-}" ]
then
    export TMPDIR="/tmp"
fi

# TODAY
# Current date. Alternatively, can use '%F' shorthand.
if [ -z "${TODAY:-}" ]
then
    TODAY="$(date +%Y-%m-%d)"
    export TODAY
fi

# USER
if [ -z "${USER:-}" ]
then
    USER="$(whoami)"
    export USER
fi

# CPU count  {{{2
# ------------------------------------------------------------------------------

if [ -z "${CPU_COUNT:-}" ]
then
    CPU_COUNT="$(_koopa_cpu_count)"
    export CPU_COUNT
fi

# History  {{{2
# ------------------------------------------------------------------------------

# See bash(1) for more options.
# For setting history length, see HISTSIZE and HISTFILESIZE.

# Standardize the history file name across shells.
if [ -z "${HISTFILE:-}" ]
then
    HISTFILE="${HOME}/.$(_koopa_shell)-history"
    export HISTFILE
    [ ! -f "$HISTFILE" ] && touch "$HISTFILE"
fi

# Don't keep duplicate lines in the history.
# Alternatively, set "ignoreboth" to also ignore lines starting with space.
if [ -z "${HISTCONTROL:-}" ]
then
    export HISTCONTROL="ignoredups"
fi

if [ -z "${HISTIGNORE:-}" ]
then
    export HISTIGNORE="&:ls:[bf]g:exit"
fi

# Set the default history size.
if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
then
    export HISTSIZE=1000
fi
if [ -z "${SAVEHIST:-}" ] || [ "${SAVEHIST:-}" -eq 0 ]
then
    export SAVEHIST=1000
fi
if [ "${HISTSIZE:-}" -ne "${SAVEHIST:-}" ]
then
    SAVEHIST="$HISTSIZE"
fi

# Add the date/time to 'history' command output.
# Note that on macOS bash will fail if 'set -e' is set and this isn't exported.
if [ -z "${HISTTIMEFORMAT:-}" ]
then
    export HISTTIMEFORMAT="%Y%m%d %T  "
fi



# Activation functions  {{{1
# ==============================================================================

_koopa_activate_xdg
_koopa_update_xdg_config
_koopa_activate_standard_paths
_koopa_activate_koopa_paths
_koopa_activate_homebrew
_koopa_activate_local_etc_profile
_koopa_activate_dircolors
_koopa_activate_gcc_colors
_koopa_activate_dotfiles
_koopa_activate_emacs
_koopa_activate_go
_koopa_activate_pipx
_koopa_activate_ruby
