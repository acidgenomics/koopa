#!/bin/sh

# Ensembl
# https://useast.ensembl.org/
# 2019-04
export ENSEMBL_RELEASE="96"
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE}"

# GENCODE
# https://www.gencodegenes.org/
# Note that they use British dates (DD-MM-YY).
# 2019-04-08
export GENCODE_HUMAN_RELEASE="30"  # GRCh38.p12
export GENCODE_MOUSE_RELEASE="M21" # GRCm38.p6

# RefSeq
# https://www.ncbi.nlm.nih.gov/refseq/
# 2019-03-20
export REFSEQ_RELEASE="93"

# FlyBase
# ftp://ftp.flybase.net/releases
# https://flybase.org/cgi-bin/get_static_page.pl?file=release_notes.html&title=Release%20Notes
export FLYBASE_RELEASE_DATE="FB2019_01"
export FLYBASE_RELEASE_VERSION="r6.26"

# WormBase
# https://wormbase.org/about/release_schedule
export WORMBASE_RELEASE_VERSION="WS269"
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"
