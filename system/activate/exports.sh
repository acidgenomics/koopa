#!/bin/sh

export KOOPA_VERSION="0.2.8"
export KOOPA_DATE="2019-02-07"

KOOPA_PLATFORM="$( python -mplatform )"
export KOOPA_PLATFORM



# Check if this is an interactive shell.
echo "$-" | grep -q "i" && export INTERACTIVE=1



# Fix systems missing $USER.
[ -z "$USER" ] && USER="$(whoami)" && export USER



# Current date (e.g. 2018-01-01).
# Alternatively, can use `%F`.
TODAY=$(date +%Y-%m-%d)
export TODAY



# Save more history.
[ -z "$HISTSIZE" ] && export HISTSIZE=100000
[ -z "$SAVEHIST" ] && export SAVEHIST=100000



# Trim the maximum number of directories in prompt (PS1).
# For bash, requires >= v4.
[ -z "$PROMPT_DIRTRIM" ] && export PROMPT_DIRTRIM=3

# Add the date/time to `history` command output.
# Note that on macOS bash will fail if `set -e` is set and this isn't exported.
[ -z "$HISTTIMEFORMAT" ] && export HISTTIMEFORMAT="%Y%m%d %T  "



# Set up text editor, if unset.
# Using vim instead of emacs by default.
if [ -z "$EDITOR" ]
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
if [ -z "$GPG_TTY" ]
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
[ -z "$RSYNC_FLAGS" ] && export RSYNC_FLAGS="--archive --copy-links --delete-before --human-readable --progress"



# R environmental variables.
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"
