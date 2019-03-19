#!/bin/sh

# Current Ensembl release.
export ENSEMBL_RELEASE="95"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"

# Current GENCODE releases.
# Note that they use British dates (DD-MM-YY).
export GENCODE_HUMAN_RELEASE="29"  # 2018-10-02 GRCh38.p12
export GENCODE_MOUSE_RELEASE="M20" # 2019-01-09 GRCm38.p6

# Current FlyBase release (for Drosophila melanogaster).
export FLYBASE_RELEASE_DATE="FB2019_01"
export FLYBASE_RELEASE_VERSION="r6.24"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"

# Current WormBase release (for Caenorhabditis elegans).
export WORMBASE_RELEASE_VERSION="WS268"

