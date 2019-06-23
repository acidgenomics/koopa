#!/bin/sh

# General global variable exports.
# Modified 2019-06-23.


# Shell type                                                                {{{1
# ==============================================================================

# Check if this is a login shell.
_koopa_is_login_bash && export LOGIN_BASH=1
_koopa_is_login_zsh && export LOGIN_ZSH=1

# Check if this is an interactive shell.
_koopa_is_interactive && export INTERACTIVE=1



# Standard globals                                                          {{{1
# ==============================================================================

# This variables are used by some koopa scripts, so ensure they're always
# consistently exported across platforms.

# HOSTNAME
[ -z "${HOSTNAME:-}" ] && HOSTNAME="$(uname -n)" && export HOSTNAME

# OSTYPE
# Automatically set by bash and zsh.
[ -z "${OSTYPE:-}" ] && 
    OSTYPE="$(bash -c "echo $OSTYPE")" &&
    export OSTYPE

# TERM
# Terminal color mode. This should normally be set by the terminal client.
[ -z "${TERM:-}" ] && export TERM="screen-256color"

# TODAY
# Current date. Alternatively, can use `%F` shorthand.
TODAY="$(date +%Y-%m-%d)" && export TODAY

# USER
[ -z "${USER:-}" ] && USER="$(whoami)" && export USER



# Interface                                                                  {{{1
# ==============================================================================

# Trim the maximum number of directories in prompt (PS1).
# For bash, requires >= v4.
[ -z "${PROMPT_DIRTRIM:-}" ] && export PROMPT_DIRTRIM=4



# History                                                                   {{{1
# ==============================================================================

[ -z "${HISTFILE:-}" ] && 
    HISTFILE="$HOME/.$(koopa shell)-history" &&
    export HISTFILE

[ -z "${HISTSIZE:-}" ] && export HISTSIZE=100000
[ -z "${SAVEHIST:-}" ] && export SAVEHIST=100000

[ -z "${HISTCONTROL:-}" ] && export HISTCONTROL="ignoredups"
[ -z "${HISTIGNORE:-}" ] && export HISTIGNORE="&:ls:[bf]g:exit"

# Add the date/time to `history` command output.
# Note that on macOS bash will fail if `set -e` is set and this isn't exported.
[ -z "${HISTTIMEFORMAT:-}" ] && export HISTTIMEFORMAT="%Y%m%d %T  "

[ -z "${PROMPT_COMMAND:-}" ] && export PROMPT_COMMAND="history -a"



# Locale / encoding                                                         {{{1
# ==============================================================================

# Force UTF-8 to avoid encoding issues for users with broken locale settings.
# https://github.com/Homebrew/brew/blob/master/Library/Homebrew/brew.sh
# > export LC_ALL="C"

[ "$(locale charmap 2>/dev/null)" != "UTF-8" ] && export LC_ALL="en_US.UTF-8"



# Editor                                                                    {{{1
# ==============================================================================

# Set up text editor, if unset.
# Using vim instead of emacs by default.
if [ -z "${EDITOR:-}" ]
then
    case _koopa_quiet_which in
        vim)
            export EDITOR="vim"
            ;;
        emacs)
            export EDITOR="emacs"
            ;;
        vi)
            export EDITOR="vi"
            ;;
    esac
fi



# CPU count                                                                 {{{1
# ==============================================================================

# Get the number of cores (CPUs) available.
# Modified 2019-06-23.
if _koopa_is_darwin
then
    CPU_COUNT="$(sysctl -n hw.ncpu)"
elif _koopa_is_linux
then
    CPU_COUNT="$(getconf _NPROCESSORS_ONLN)"
else
    # Otherwise assume single threaded.
    CPU_COUNT=1
fi
export CPU_COUNT



# Program-specific                                                          {{{1
# ==============================================================================

# GnuPGP                                                                    {{{2
# ------------------------------------------------------------------------------

# Enable passphrase prompting in terminal.
# Note that this step will error if tty isn't installed.
[ -z "${GPG_TTY:-}" ] && GPG_TTY="$(tty)" && export GPG_TTY

# Ruby                                                                      {{{2
# ------------------------------------------------------------------------------

[ -d "${HOME}/.gem" ] && export GEM_HOME="${HOME}/.gem"

# rsync                                                                     {{{2
# ------------------------------------------------------------------------------

# Useful flags:
# -a, --archive               archive mode; equals -rlptgoD (no -H,-A,-X)
# -z, --compress              compress file data during the transfer
# -L, --copy-links            transform symlink into referent file/dir
#     --delete-before         receiver deletes before xfer, not during
# -h, --human-readable        output numbers in a human-readable format
#     --iconv=CONVERT_SPEC    request charset conversion of filenames
#     --progress              show progress during transfer
#     --dry-run
#     --one-file-system
#     --acls --xattrs
#     --iconv=utf-8,utf-8-mac

[ -z "${RSYNC_FLAGS:-}" ] &&
    RSYNC_FLAGS="$(_koopa_rsync_flags)" &&
    export RSYNC_FLAGS
