#!/bin/sh

# CPI shared shell configuration.
# Updated 2019-10-29 by Michael Steinbaugh.



# Notes                                                                     {{{1
# ==============================================================================

# Do not set 'LD_LIBRARY_PATH'.
# Use '/etc/ld.so.conf.d/' method instead.
# Run 'sudo ldconfig' to update shared libraries.

# Do not set 'R_HOME' or 'JAVA_HOME'.



# Koopa                                                                     {{{1
# ==============================================================================

export KOOPA_USERS_NO_EXTRA="bioinfo barbara.bryant"
export KOOPA_USERS_SKIP="michael.steinbaugh phil.drapeau"



# Azure Files                                                               {{{1
# ==============================================================================

export D1="/mnt/azbioinfoseq01"
export D2="/mnt/azbioinfoseq02"
export D3="/mnt/azbioinfoseq03"
export D4="/mnt/azbioinfoseq04"
export D5="/mnt/azbioinfoseq05"



# Cell Ranger                                                               {{{1
# ==============================================================================

# > PATH="${PATH}:/usr/local/cellranger/2.1.0"
# > PATH="${PATH}:/usr/local/cellranger/3.0.0"
# > PATH="${PATH}:/usr/local/cellranger/3.0.2"
PATH="${PATH}:/usr/local/cellranger/3.1.0"
PATH="${PATH}:/usr/local/cellranger-atac/1.1.0"



# Oracle                                                                    {{{1
# ==============================================================================

# Configuration moved to '/usr/local/lib64/R/etc/Renviron.site'.
# Refer to "ROracle" section.



# Shiny                                                                     {{{1
# ==============================================================================

# Consider setting this in 'Renviron.site' instead.
export SHINYAPPDATA="/mnt/azbioifnoseq05/appdata"

alias shinyrestart="sudo systemctl restart shiny-server"
alias shinystart="sudo systemctl start shiny-server"
alias shinystatus="sudo systemctl status shiny-server"




# Custom programs                                                           {{{1
# ==============================================================================

PATH="${PATH}:/mnt/azbioinfoseq01/projects/checksum"
export PATH
