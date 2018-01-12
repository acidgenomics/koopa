alias e="exit"

# Interactive queues
alias i="seqcloud interactive"
alias i2="seqcloud interactive_64gb"

# ls
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -lh"

# Disable R prompt to save workspace
alias R="R --no-save"

# export PROMPT_DIRTRIM=2

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
# -r, --recursive             recurse into directories
# -t, --times                 preserve modification times
export RSYNC_FLAGS="--archive --delete-before --human-readable --progress --recursive --times"

export TODAY=$(date +%Y-%m-%d)

# Annotation database paths
export ENSEMBL_RELEASE="91"
export ENSEMBL_RELEASE_PATH="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"
export FLYBASE_RELEASE="FB2017_06"
export FLYBASE_RELEASE_VERSION="6.19"
export FLYBASE_RELEASE_PATH="ftp://ftp.flybase.net/releases/$FLYBASE_RELEASE/dmel_r${FLYBASE_RELEASE_VERSION}"
