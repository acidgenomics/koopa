#!/bin/sh

# Check if this is a login shell.
[ "$0" = "-bash" ] && export LOGIN_BASH=1
[ "$0" = "-zsh" ] && export LOGIN_ZSH=1

# Check if this is an interactive shell.
echo "$-" | grep -q "i" && export INTERACTIVE=1

# Ensure $USER is always exported.
[ -z "${USER:-}" ] && USER="$(whoami)" && export USER

# Ensure terminal color mode is defined.
# Normally, this should be set by the terminal client.
[ -z "${TERM:-}" ] && export TERM="screen-256color"

# Force export of current date (e.g. 2018-01-01).
# Alternatively, can use `%F`.
TODAY=$(date +%Y-%m-%d)
export TODAY

# History
[ -z "${HISTFILE:-}" ] && export HISTFILE="$HOME/.${KOOPA_SHELL}_history"
[ -z "${HISTSIZE:-}" ] && export HISTSIZE=100000
[ -z "${SAVEHIST:-}" ] && export SAVEHIST=100000
[ -z "${HISTCONTROL:-}" ] && export HISTCONTROL="ignoredups"
[ -z "${HISTIGNORE:-}" ] && export HISTIGNORE="&:ls:[bf]g:exit"
[ -z "${PROMPT_COMMAND:-}" ] && export PROMPT_COMMAND="history -a"

# Trim the maximum number of directories in prompt (PS1).
# For bash, requires >= v4.
[ -z "${PROMPT_DIRTRIM:-}" ] && export PROMPT_DIRTRIM=4

# Add the date/time to `history` command output.
# Note that on macOS bash will fail if `set -e` is set and this isn't exported.
[ -z "${HISTTIMEFORMAT:-}" ] && export HISTTIMEFORMAT="%Y%m%d %T  "

# Force UTF-8 to avoid encoding issues for users with broken locale settings.
# https://github.com/Homebrew/brew/blob/master/Library/Homebrew/brew.sh
# > export LC_ALL="C"
if [ "$(locale charmap 2>/dev/null)" != "UTF-8" ]
then
    export LC_ALL="en_US.UTF-8"
fi

# Set up text editor, if unset.
# Using vim instead of emacs by default.
if [ -z "${EDITOR:-}" ]
then
    if quiet_which vim
    then
        export EDITOR="vim"
    elif quiet_which vi
    then
        export EDITOR="vi"
    fi
fi

# GnuPGP.
# Enable passphrase prompting in terminal.
# Note that this step will error if tty isn't installed.
if [ -z "${GPG_TTY:-}" ]
then
    GPG_TTY="$(tty)"
    export GPG_TTY
fi

# Ruby gems.
[ -d "${HOME}/.gem" ] && export GEM_HOME="${HOME}/.gem"

# rsync flags.
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
[ -z "${RSYNC_FLAGS:-}" ] && export RSYNC_FLAGS="--archive --copy-links --delete-before --human-readable --progress"

# R environmental variables.
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"
