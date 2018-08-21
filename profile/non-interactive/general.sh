# Global definitions ===========================================================
if [[ -f "/etc/bashrc" ]]; then
    . "/etc/bashrc"
fi

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
export RSYNC_FLAGS="--archive --copy-links --delete-before --human-readable --progress"

export TODAY=$(date +%Y-%m-%d)

# Genome versions ==============================================================
# Ensembl
# Match latest release supported in Bioconductor ensembldb
export ENSEMBL_RELEASE="92"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"

# Gencode
export GENCODE_RELEASE="28"

# FlyBase
export FLYBASE_RELEASE_DATE="FB2018_03"
export FLYBASE_RELEASE_VERSION="r6.22"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"

# WormBase
export WORMBASE_RELEASE_VERSION="WS265"
