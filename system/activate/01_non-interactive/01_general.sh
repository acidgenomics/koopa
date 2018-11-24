#!/usr/bin/env bash

# General file sources and exports.

# Sources ======================================================================
# Global definitions.
[[ -f /etc/bashrc ]] && . /etc/bashrc

# Enable bash completion.
# This will fail if `set -u` is enabled.
[[ -f /usr/local/etc/bash_completion ]] && . /usr/local/etc/bash_completion

# Exports ======================================================================
# Ruby gems
export GEM_HOME="${HOME}/.gem"

# GnuPGP
# Enable passphrase prompting in terminal.
export GPG_TTY=$(tty)

# Add the date/time to `history` command output.
# Note that on macOS bash will fail if `set -e` is set and this isn't exported.
export HISTTIMEFORMAT="%Y%m%d %T  "

# Homebrew now supports a global variable to force bottle installations.
# https://github.com/Homebrew/brew/pull/4520/files
# https://github.com/Homebrew/brew/pull/4542/files
export HOMEBREW_FORCE_BOTTLE="1"

# R environmental variables
export R_DEFAULT_PACKAGES="stats,graphics,grDevices,utils,datasets,methods,base"

# rsync
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
export RSYNC_FLAGS="--archive --copy-links --delete-before --human-readable --progress"
export RSYNC_FLAGS_APFS="${RSYNC_FLAGS} --iconv=utf-8,utf-8-mac"

export TODAY=$(date +%Y-%m-%d)

# Genome versions ==============================================================
# Ensembl
export ENSEMBL_RELEASE="94"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"

# Gencode
export GENCODE_RELEASE="29"

# FlyBase
export FLYBASE_RELEASE_DATE="FB2018_05"
export FLYBASE_RELEASE_VERSION="r6.24"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"

# WormBase
export WORMBASE_RELEASE_VERSION="WS266"

# Set Builtin ==================================================================
# NOTE: Don't attempt to enable strict mode in login scripts.

# Use vi mode instead of emacs by default.
set -o vi
