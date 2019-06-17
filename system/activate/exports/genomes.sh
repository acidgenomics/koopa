#!/bin/sh

# Genome versions.
# Modified 2019-06-16.



# Ensembl                                                                   {{{1
# ==============================================================================
# https://useast.ensembl.org/
export ENSEMBL_RELEASE_DATE="2019-04"
export ENSEMBL_RELEASE_VERSION="96"
# FIXME Take this out.
export ENSEMBL_RELEASE_URL="ftp://ftp.ensembl.org/pub/release-${ENSEMBL_RELEASE_VERSION}"



# GENCODE                                                                   {{{1
# ==============================================================================
# https://www.gencodegenes.org/
# Note that they use British dates (DD-MM-YY).
export GENCODE_RELEASE_DATE="2019-04-08"
export GENCODE_HUMAN_RELEASE_VERSION="30"  # GRCh38.p12
export GENCODE_MOUSE_RELEASE_VERSION="M21" # GRCm38.p6



# RefSeq                                                                    {{{1
# ==============================================================================
# https://www.ncbi.nlm.nih.gov/refseq/
export REFSEQ_RELEASE_DATE="2019-05-17"
export REFSEQ_RELEASE_VERSION="94"



# FlyBase                                                                   {{{1
# ==============================================================================
# Support for this may be removed in a future release, due to paywall.
# ftp://ftp.flybase.net/releases
# https://flybase.org/cgi-bin/get_static_page.pl?file=release_notes.html
export FLYBASE_RELEASE_DATE="FB2019_03"
export FLYBASE_RELEASE_VERSION="r6.28"
# FIXME Take this out.
export FLYBASE_RELEASE_URL="ftp://ftp.flybase.net/releases/${FLYBASE_RELEASE_DATE}/dmel_${FLYBASE_RELEASE_VERSION}"



# WormBase                                                                  {{{1
# ==============================================================================
# https://wormbase.org/about/release_schedule
export WORMBASE_RELEASE_VERSION="WS270"
