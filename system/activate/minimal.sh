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

# GROUP  {{{2
# ------------------------------------------------------------------------------

if [ -z "${GROUP:-}" ]
then
    GROUP="$(id -gn)"
fi
export GROUP

# HOSTNAME  {{{2
# ------------------------------------------------------------------------------

if [ -z "${HOSTNAME:-}" ]
then
    HOSTNAME="$(uname -n)"
fi
export HOSTNAME

# OSTYPE  {{{2
# ------------------------------------------------------------------------------

# Automatically set by bash and zsh.
if [ -z "${OSTYPE:-}" ]
then
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
fi
export OSTYPE

# SHELL  {{{2
# ------------------------------------------------------------------------------

# Some POSIX shells, such as Dash, don't export this by default.
# Note that this doesn't currently get set by RStudio terminal.
if [ -z "${SHELL:-}" ]
then
    SHELL="$(_koopa_which "$KOOPA_SHELL")"
fi
export SHELL

# TMPDIR  {{{2
# ------------------------------------------------------------------------------

if [ -z "${TMPDIR:-}" ]
then
    TMPDIR="/tmp"
fi
export TMPDIR

# TODAY  {{{2
# ------------------------------------------------------------------------------

# Current date. Alternatively, can use '%F' shorthand.
if [ -z "${TODAY:-}" ]
then
    TODAY="$(date +%Y-%m-%d)"
fi
export TODAY

# USER  {{{2
# ------------------------------------------------------------------------------

# Alternatively, can use 'whoami' here.
if [ -z "${USER:-}" ]
then
    USER="$(id -un)"
fi
export USER

# History  {{{2
# ------------------------------------------------------------------------------

# See bash(1) for more options.
# For setting history length, see HISTSIZE and HISTFILESIZE.

# Standardize the history file name across shells.
# Note that snake case is commonly used here across platforms.
if [ -z "${HISTFILE:-}" ]
then
    HISTFILE="${HOME}/.$(_koopa_shell)_history"
fi
export HISTFILE

# Create the history file, if necessary.
# Note that the HOME check here hardens against symlinked data disk failure.
if [ ! -f "$HISTFILE" ] && [ -e "${HOME:-}" ]
then
    touch "$HISTFILE"
fi

# Don't keep duplicate lines in the history.
# Alternatively, set "ignoreboth" to also ignore lines starting with space.
if [ -z "${HISTCONTROL:-}" ]
then
    HISTCONTROL="ignoredups"
fi
export HISTCONTROL

if [ -z "${HISTIGNORE:-}" ]
then
    HISTIGNORE="&:ls:[bf]g:exit"
fi
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
if [ "${HISTSIZE:-}" != "${SAVEHIST:-}" ]
then
    SAVEHIST="$HISTSIZE"
fi
export SAVEHIST

# CPU count  {{{2
# ------------------------------------------------------------------------------

if [ -z "${CPU_COUNT:-}" ]
then
    CPU_COUNT="$(_koopa_cpu_count)"
fi
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
    if [ -e "/usr/local/share/proj" ]
    then
        PROJ_LIB="/usr/local/share/proj"
        export PROJ_LIB
    elif [ -e "/usr/share/proj" ]
    then
        PROJ_LIB="/usr/share/proj"
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
# This function can cause shell lockout on Ubuntu 20.
# > _koopa_activate_local_etc_profile
_koopa_activate_dircolors
_koopa_activate_gcc_colors
_koopa_activate_dotfiles
_koopa_activate_emacs
_koopa_activate_go
_koopa_activate_openjdk
_koopa_activate_pipx
_koopa_activate_ruby
