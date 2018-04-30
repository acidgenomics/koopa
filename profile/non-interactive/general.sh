# Aliases ======================================================================
alias e="exit"

# Interactive queue
alias i="seqcloud interactive"

# ls
alias la="ls -a"
alias lF="ls -F"
alias ll="ls -lh"

# Disable R prompt to save workspace
alias R="R --no-save"

# Exports ======================================================================
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

# Ensembl
# Match latest release available in AnnotationHub (Bioconductor 3.7)
export ENSEMBL_RELEASE="92"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"

# FlyBase
export FLYBASE_RELEASE_DATE="FB2018_02"
export FLYBASE_RELEASE_VERSION="r6.21"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"
