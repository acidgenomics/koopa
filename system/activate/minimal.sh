#!/bin/sh



# Pre-flight checks  {{{1
# ==============================================================================

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
[ -z "${HOSTNAME:-}" ] && HOSTNAME="$(uname -n)"
export HOSTNAME

# OSTYPE
# Automatically set by bash and zsh.
[ -z "${OSTYPE:-}" ] && OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
export OSTYPE

# SHELL
# Some POSIX shells, such as Dash, don't export this by default.
# Note that this doesn't currently get set by RStudio terminal.
SHELL="$(_koopa_which_realpath "$KOOPA_SHELL")"
export SHELL

# TMPDIR
[ -z "${TMPDIR:-}" ] && TMPDIR="/tmp"
export TMPDIR

# TODAY
# Current date. Alternatively, can use '%F' shorthand.
[ -z "${TODAY:-}" ] && TODAY="$(date +%Y-%m-%d)"
export TODAY

# USER
[ -z "${USER:-}" ] && USER="$(whoami)"
export USER

# History  {{{2
# ------------------------------------------------------------------------------

# See bash(1) for more options.
# For setting history length, see HISTSIZE and HISTFILESIZE.

# Standardize the history file name across shells.
# Note that snake case is commonly used here across platforms.
[ -z "${HISTFILE:-}" ] && HISTFILE="${HOME}/.$(_koopa_shell)_history"
export HISTFILE
[ ! -f "$HISTFILE" ] && touch "$HISTFILE"

# Don't keep duplicate lines in the history.
# Alternatively, set "ignoreboth" to also ignore lines starting with space.
[ -z "${HISTCONTROL:-}" ] && HISTCONTROL="ignoredups"
export HISTCONTROL

[ -z "${HISTIGNORE:-}" ] && HISTIGNORE="&:ls:[bf]g:exit"
export HISTIGNORE

# Set the default history size.
if [ -z "${HISTSIZE:-}" ] || [ "${HISTSIZE:-}" -eq 0 ]
then
    HISTSIZE=1000
fi
export HISTSIZE

# Add the date/time to 'history' command output.
# Note that on macOS bash will fail if 'set -e' is set and this isn't exported.
if [ -z "${HISTTIMEFORMAT:-}" ]
then
    HISTTIMEFORMAT="%Y%m%d %T  "
fi
export HISTTIMEFORMAT

# Ensure that HISTSIZE and SAVEHIST values match.
[ "${HISTSIZE:-}" != "${SAVEHIST:-}" ] && SAVEHIST="$HISTSIZE"
export SAVEHIST

# CPU count  {{{2
# ------------------------------------------------------------------------------

[ -z "${CPU_COUNT:-}" ] && CPU_COUNT="$(_koopa_cpu_count)"
export CPU_COUNT



# Package configuration  {{{1
# ==============================================================================

# These are defined primarily for R environment.
# In particular these make building tricky pages from source, such as rgdal,
# sf and others a lot easier.

# This is necessary for rgdal, sf packages to install clean.
if [ -z "${PKG_CONFIG_PATH:-}" ]
then
    PKG_CONFIG_PATH="\
/usr/local/lib64/pkgconfig:\
/usr/local/lib/pkgconfig:\
/usr/lib64/pkgconfig:\
/usr/lib/pkgconfig"
    export PKG_CONFIG_PATH
fi

if [ -z "${PROJ_LIB:-}" ]
then
    if [ -e '/usr/local/share/proj' ]
    then
        PROJ_LIB='/usr/local/share/proj'
        export PROJ_LIB
    elif [ -e '/usr/share/proj' ]
    then
        PROJ_LIB='/usr/share/proj'
        export PROJ_LIB
    fi
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
_koopa_activate_openjdk
_koopa_activate_pipx
_koopa_activate_ruby
