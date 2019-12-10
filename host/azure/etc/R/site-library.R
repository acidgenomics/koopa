install.packages("BiocManager")
install.packages("remotes")

library(BiocManager)
library(remotes)



## CRAN ====
install("Rcpp")
install("RcppArmadillo")
install("RcppRoll")
install("data.table")
install("dplyr")
install("shiny")
install("shinydashboard")
install("tidyverse")
install("rgl")

install("ADGofTest")
install("CVST")
install("DT")
install("DiagrammeR")
install("GSA")
install("KMsurv")
install("Seurat")
install("VennDiagram")
install("ade4")
install("assertr")
install("available")
install("aws.signature")
install("bindr")
install("bindrcpp")
install("caret")
install("cmprsk")
install("dimRed")
install("diptest")
install("downloader")
install("dynamicTreeCut")
install("exactRankTests")
install("flexmix")
install("fpc")
install("ggpubr")
install("ggsci")
install("ggsignif")
install("janitor")
install("km.ci")
install("lars")
install("maxstat")
install("mixtools")
install("mongolite")
install("morpheus")
install("msigdbr")
install("profvis")
install("pspline")
install("rentrez")
install("snakecase")
install("stabledist")
install("survMisc")
install("survminer")
install("tesseract")
install("trimcluster")
install("varhandle")
install("visNetwork")
install("xlsx")



## Bioconductor ====
install("BiocCheck")
install("BiocVersion")
install("ChIPpeakAnno")
install("ChIPseeker")
install("DESeq2")
install("DiffBind")
install("GEOquery")
install("GenomicFiles")
install("Homo.sapiens")
install("OrganismDbi")
install("Rqc")
install("TxDb.Hsapiens.UCSC.hg19.knownGene")
install("TxDb.Hsapiens.UCSC.hg38.knownGene")
install("bamsignals")
install("biovizBase")
install("bumphunter")
install("ddalpha")
install("derfinder")
install("derfinderHelper")
install("ggbio")
install("monocle")
install("scater")
install("scran")



## GitHub ====
install_github("cole-trapnell-lab/monocle3")

install_github("acidgenomics/basejump")
install_github("acidgenomics/acidplots")
install_github("acidgenomics/bcbioRNASeq")
install_github("acidgenomics/bcbioSingleCell")
install_github("acidgenomics/DESeqAnalysis")
install_github("acidgenomics/pfgsea")
install_github("acidgenomics/Chromium")
install_github("acidgenomics/pointillism")

install_github("acidgenomics/lintr")
install_github("acidgenomics/bb8")



## Problematic ====
## > install("ROracle")
## http://cran.cnr.berkeley.edu/web/packages/ROracle/INSTALL
## OCI libraries not found

## Ubuntu 18 on AWS:
## configure: error: "/usr/lib/oracle/12.2/client64/lib" directory does not exist
## ERROR: configuration failed for package ‘ROracle’
## * removing ‘/mnt/data01/n/app/r/3.6/site-library/ROracle’



## CPI internal ====

# Install from a private GitLab repo.

# https://community.rstudio.com/t/how-to-install-gitlab-from-a-private-repository/26801/4

# Otherwise, will hit:
# git2r_remote_ls error

cred <- git2r::cred_user_pass(
    rstudioapi::askForPassword("username"),
    rstudioapi::askForPassword("Password")
)
remotes::install_git(
   url = "git@gitlab.com:cpi-bioinfo/packages/cpichipseq.git",
   credentials = cred
)

## > remotes::install_gitlab("cpi-bioinfo/packages/cpichipseq")



## Failures / warnings ====

## dimRed > pcaL1
## Fedora: coin-or-Clp
## Doesn't seem to be available via yum...
## checking Clp_C_Interface.h presence... no
## checking for Clp_C_Interface.h... no
## configure: error: Could not find Clp_C_Interface.h:
##     pcaL1 requires clp from http://www.coin-or.org/projects/Clp.xml
## use --with-clp-include or CLP_INCLUDE to specify the include path.
## ERROR: configuration failed for package ‘pcaL1’
## * removing ‘/data00/R/site-library/3.6/pcaL1’
## Warning in install.packages(pkgs = doing, lib = lib, repos = repos, ...) :
##     installation of package ‘pcaL1’ had non-zero exit status
# Calls: install ... <Anonymous> -> .install -> .install_repos -> install.packages



## rgl warning
## installing to /data00/R/site-library/3.6/00LOCK-rgl/00new/rgl/libs
## Warning in rgl.init(initValue, onlyNULL) :
##     RGL: unable to open X11 display
## Calls: <Anonymous> ... tryCatchList -> tryCatchOne -> doTryCatch -> fun -> rgl.init
## Warning: 'rgl_init' failed, running with rgl.useNULL = TRUE
## ** checking absolute paths in shared objects and dynamic libraries
## ** testing if installed package can be loaded from final location
## Warning in rgl.init(initValue, onlyNULL) :
##     RGL: unable to open X11 display
## Calls: <Anonymous> ... tryCatchList -> tryCatchOne -> doTryCatch -> fun -> rgl.init
## Warning: 'rgl_init' failed, running with rgl.useNULL = TRUE
## ** testing if installed package keeps a record of temporary installation path
## * DONE (rgl)



## av failure
## ffmpeg-devel not available
## https://rpmfusion.org/Configuration
## http://li.nux.ro/
## rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm
## yum install ffmpeg ffmpeg-devel -y
