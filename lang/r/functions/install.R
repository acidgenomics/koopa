#' Install recommended default R packages
#' @note Updated 2020-08-11.
#' @noRd
installDefaultPackages <- function() {
    requireNamespaces("bb8")
    install <- bb8::install
    args <- parseArgs(
        flags = "all",
        positionalArgs = FALSE
    )
    all <- "all" %in% args[["flags"]]
    ## These dependencies are required to install sf, etc.
    assert(allAreSystemCommands(c("gdal-config", "geos-config")))
    ## Check for GitHub PAT, if necessary.
    if (isTRUE(all)) {
        assert(hasGitHubPAT())
    }
    ## Ensure BiocManager is installed.
    if (!isTRUE(requireNamespace("BiocManager", quietly = TRUE))) {
        stopifnot(requireNamespace("utils"), quietly = TRUE)
        utils::install.packages("BiocManager")
    }
    ## Enable versioned Bioconductor install.
    biocVersion <- Sys.getenv("BIOC_VERSION")
    if (isString(biocVersion)) {
        message(sprintf("Installing Bioconductor %s.", biocVersion))
        BiocManager::install(update = FALSE, ask = FALSE, version = biocVersion)
    }
    h1("Install R packages")
    h2("Tricky packages")
    ## - [2020-08-05] rgdal v1.5-15 won't build on Debian.
    ##   Fixed with v1.5-16.
    ## - [2020-08-11] cpp11 v0.2.0 update is breaking tidyr.
    ##   https://github.com/tidyverse/tidyr/issues/1024
    cranArchive <- "https://cran.r-project.org/src/contrib/Archive/"
    install(
        pkgs = c(
            paste0(cranArchive, "cpp11/cpp11_0.1.0.tar.gz"),
            "Rcpp",
            "RcppArmadillo",
            "RcppAnnoy",
            "XML",
            "rJava",
            "rgdal",
            "sf"
        ),
        reinstall = FALSE
    )
    h2("CRAN")
    install(
        pkgs = c(
            "DT",
            "Matrix",
            "R.utils",
            "Rcpp",
            "RcppArmadillo",
            "backports",
            "caTools",
            "cli",
            "covr",
            "cowplot",
            "curl",
            "data.table",
            "desc",
            "devtools",
            "ggrepel",
            "git2r",
            "httr",
            "knitr",
            "lintr",
            "magrittr",
            "matrixStats",
            "parallel",
            "patrick",
            "pbapply",
            "pkgdown",
            "rcmdcheck",
            "remotes",
            "reprex",
            "reticulate",
            "rlang",
            "rmarkdown",
            "roxygen2",
            "sessioninfo",
            "shiny",
            "shinydashboard",
            "stringi",
            "testthat",
            "tidyverse",
            "usethis",
            "viridis",
            "vroom",
            "xmlparsedata"
        ),
        reinstall = FALSE
    )
    ## https://www.bioconductor.org/packages/release/BiocViews.html#___Software
    h2("Bioconductor")
    install(
        pkgs = c(
            "AnnotationDbi",
            "AnnotationHub",
            "Biobase",
            "BiocCheck",
            "BiocFileCache",
            "BiocGenerics",
            "BiocNeighbors",
            "BiocParallel",
            "BiocSingular",
            "BiocStyle",
            "BiocVersion",
            "Biostrings",
            "DelayedArray",
            "DelayedMatrixStats",
            "GenomeInfoDb",
            "GenomeInfoDbData",
            "GenomicAlignments",
            "GenomicFeatures",
            "GenomicRanges",
            "IRanges",
            "S4Vectors",
            "SingleCellExperiment",
            "SummarizedExperiment",
            "XVector",
            "ensembldb",
            "rtracklayer",
            "zlibbioc"
        ),
        reinstall = FALSE
    )
    if (!isTRUE(all)) {
        quit()
    }
    h1("Install additional R packages ({.arg --all} mode)")
    h2("CRAN")
    install(
        pkgs = c(
            "NMF",
            "R.oo",
            "R6",
            "Seurat",
            "UpSetR",
            "WGCNA",
            "ashr",
            "available",
            "bookdown",
            "cgdsr",  # cBioPortal
            "datapasta",
            "dbplyr",
            "dendextend",
            "dendsort",
            "dynamicTreeCut",
            "fastICA",
            "fastcluster",
            "fastmatch",
            "fdrtool",
            "fs",
            "future",
            "ggdendro",
            "ggrepel",
            "ggridges",
            "ggupset",
            "gprofiler2",
            "hexbin",
            "htmlwidgets",
            "janitor",
            "jsonlite",
            "languageserver",
            "memoise",
            "openxlsx",
            "packrat",
            "pheatmap",
            "pillar",
            "plyr",
            "pryr",
            "pzfx",
            "rdrop2",
            "readxl",
            "reshape2",
            "rio",
            "shinycssloaders",
            "slam",
            "snakecase",
            "snow",
            "uwot"
        ),
        reinstall = FALSE
    )
    h2("Bioconductor")
    install(
        pkgs = c(
            "AnnotationFilter",                         # Annotation
            "BSgenome.Hsapiens.NCBI.GRCh38",            # AnnotationData
            "BSgenome.Hsapiens.UCSC.hg19",              # AnnotationData
            "BSgenome.Hsapiens.UCSC.hg38",              # AnnotaitonData
            "BSgenome.Mmusculus.UCSC.mm10",             # AnnotationData
            "ChIPpeakAnno",                             # ChIPSeq
            "ComplexHeatmap",                           # Visualization
            "ConsensusClusterPlus",                     # Visualization
            "DESeq2",                                   # RNASeq
            "DEXSeq",                                   # RNASeq
            "DNAcopy",                                  # CopyNumberVariation
            "DOSE",                                     # Pathways
            "DiffBind",                                 # ChIPSeq
            "DropletUtils",                             # SingleCell
            "EDASeq",                                   # RNASeq
            "EnhancedVolcano",                          # Visualization
            "EnsDb.Hsapiens.v75",                       # AnnotationData
            "EnsDb.Hsapiens.v86",                       # AnnotationData
            "ExperimentHub",                            # Annotation
            "GEOquery",                                 # Annotation
            "GOSemSim",                                 # Pathways
            "GSEABase",                                 # Pathways
            "GSVA",                                     # Pathways
            "Gviz",                                     # Visualization
            "HDF5Array",                                # DataRepresentation
            "HSMMSingleCell",                           # SingleCell
            "IHW",                                      # RNASeq
            "KEGG.db",                                  # AnnotationData
            "KEGGREST",                                 # Pathways
            "KEGGgraph",                                # Visualization
            "MAST",                                     # RNASeq
            "MultiAssayExperiment",                     # DataRepresentation
            "ReactomePA",                               # Pathways
            "Rhdf5lib",                                 # DataRepresentation
            "Rhtslib",                                  # DataRepresentation
            "Rsamtools",                                # Alignment
            "Rsubread",                                 # Alignment
            "SC3",                                      # SingleCell
            "SpidermiR",                                # miRNA
            "STRINGdb",                                 # Pathways
            "ShortRead",                                # Alignment
            "TargetScore",                              # miRNA
            "TCGAbiolinks",                             # Sequencing
            "TxDb.Hsapiens.UCSC.hg19.knownGene",        # AnnotationData
            "TxDb.Hsapiens.UCSC.hg38.knownGene",        # AnnotationData
            "TxDb.Mmusculus.UCSC.mm10.knownGene",       # AnnotationData
            "VariantAnnotation",                        # Annotation
            "apeglm",                                   # RNASeq
            "ballgown",                                 # RNASeq
            "batchelor",                                # SingleCell
            "beachmat",                                 # SingleCell
            "biomaRt",                                  # Annotation
            "biovizBase",                               # Visualization
            "cBioPortalData",                           # RNASeq
            "cbaf",                                     # RNASeq
            "clusterProfiler",                          # Pathways
            "csaw",                                     # ChIPSeq
            "destiny",                                  # SingleCell
            "edgeR",                                    # RNASeq
            "enrichplot",                               # Visualization
            "fgsea",                                    # Pathways
            "fishpond",                                 # RNASeq
            "gage",                                     # Pathways
            "genefilter",                               # Microarray
            "geneplotter",                              # Visualization
            "ggbio",                                    # Visualization
            "ggtree",                                   # Visualization
            "goseq",                                    # Pathways
            "isomiRs",                                  # miRNA
            "limma",                                    # RNASeq
            "miRBaseConverter",                         # miRNA
            "miRNApath",                                # miRNA
            "miRNAtap",                                 # miRNA
            "mirbase.db",                               # AnnotationData
            "multiMiR",                                 # miRNA
            "multtest",                                 # MultipleComparison
            "org.Hs.eg.db",                             # AnnotationData
            "org.Mm.eg.db",                             # AnnotationData
            "pathview",                                 # Pathways
            "pcaMethods",                               # Bayesian
            "reactome.db",                              # AnnotationData
            "rhdf5",                                    # DataRepresentation
            "scater",                                   # SingleCell
            "scone",                                    # SingleCell
            "scran",                                    # SingleCell
            "sctransform",                              # SingleCell
            "slalom",                                   # SingleCell
            "splatter",                                 # SingleCell
            "targetscan.Hs.eg.db",                      # miRNA
            "tximeta",                                  # RNASeq
            "tximport",                                 # RNASeq
            "vsn",                                      # Visualization
            "zinbwave"                                  # SingleCell
        ),
        reinstall = FALSE
    )
    ## GitHub packages.
    h2("GitHub")
    install(
        pkgs = c(
            "acidgenomics/bb8",                         # Infrastructure
            "acidgenomics/acidroxygen",                 # Infrastructure
            "acidgenomics/acidtest",                    # Infrastructure
            "acidgenomics/basejump",                    # Infrastructure
            "acidgenomics/acidplots",                   # Visualization
            "acidgenomics/EggNOG",                      # Annotation
            "acidgenomics/PANTHER",                     # Annotation
            "acidgenomics/WormBase",                    # Annotation
            "acidgenomics/DESeqAnalysis",               # RNASeq
            "acidgenomics/acidgsea",                    # RNASeq
            "acidgenomics/Chromium",                    # SingleCell
            "acidgenomics/pointillism",                 # SingleCell
            "hbc/bcbioRNASeq",                          # RNASeq
            "hbc/bcbioSingleCell"                       # SingleCell
            ## > "BaderLab/scClustViz"                  # SingleCell
            ## > "cole-trapnell-lab/monocle3"           # SingleCell
            ## > "jonocarroll/DFplyr"                   # DataRepresentation
            ## > "js229/Vennerable"                     # Visualization
            ## > "kevinblighe/scDataviz"                # SingleCell
            ## > "waldronlab/cBioPortalData"            # RNASeq
        ),
        reinstall = FALSE
    )
    message("Installation of R packages was successful.")
}

#' Install packages from GitHub
#'
#' This is a stripped down version of `bb8::installGitHub()`.
#'
#' @note Updated 2020-04-09.
#' @noRd
.installGitHub <- function(
    repo,
    release = "latest",
    reinstall = FALSE
) {
    stopifnot(
        requireNamespace("utils", quietly = TRUE),
        all(grepl(x = repo, pattern = "^[^/]+/[^/]+$")),
        is.character(release) && identical(length(release), 1L),
        is.logical(reinstall) && identical(length(reinstall), 1L)
    )
    if (length(repo) > 1L && identical(release, "latest")) {
        release <- rep(release, times = length(repo))
    }
    stopifnot(identical(length(repo), length(release)))
    out <- mapply(
        repo = repo,
        release = release,
        MoreArgs = list(reinstall = reinstall),
        FUN = function(repo, release, reinstall) {
            ## > owner <- dirname(repo)
            pkg <- basename(repo)
            if (
                !isTRUE(reinstall) &&
                isTRUE(pkg %in% rownames(utils::installed.packages()))
            ) {
                message(sprintf("'%s' is already installed.", pkg))
                return(repo)
            }
            ## Get the tarball URL.
            if (identical(release, "latest")) {
                jsonUrl <- paste(
                    "https://api.github.com",
                    "repos",
                    repo,
                    "releases",
                    "latest",
                    sep = "/"
                )
                json <- withCallingHandlers(expr = {
                    tryCatch(expr = readLines(jsonUrl))
                }, warning = function(w) {
                    ## Ignore warning about missing final line in JSON return.
                    if (grepl(
                        pattern = "incomplete final line",
                        x = conditionMessage(w)
                    )) {
                        invokeRestart("muffleWarning")
                    }
                })
                ## Extract the tarball URL from the JSON output using base R.
                x <- unlist(strsplit(x = json, split = ",", fixed = TRUE))
                x <- grep(pattern = "tarball_url", x = x, value = TRUE)
                x <- strsplit(x = x, split = "\"", fixed = TRUE)[[1L]][[4L]]
                url <- x
            } else {
                url <- paste(
                    "https://github.com",
                    repo,
                    "archive",
                    paste0(release, ".tar.gz"),
                    sep = "/"
                )
            }
            tarfile <- tempfile(fileext = ".tar.gz")
            utils::download.file(
                url = url,
                destfile = tarfile,
                quiet = FALSE
            )
            ## Using a random string of 'A-Za-z' here for extracted directory.
            exdir <- file.path(
                tempdir(),
                paste0(
                    "untar-",
                    paste0(
                        sample(c(LETTERS, letters))[1L:6L],
                        collapse = ""
                    )
                )
            )
            utils::untar(
                tarfile = tarfile,
                exdir = exdir,
                verbose = TRUE
            )
            ## Locate the extracted package directory.
            pkgdir <- list.dirs(
                path = exdir,
                full.names = TRUE,
                recursive = FALSE
            )
            stopifnot(
                identical(length(pkgdir), 1L),
                isTRUE(dir.exists(pkgdir))
            )
            utils::install.packages(
                pkgs = pkgdir,
                repos = NULL,
                type = "source"
            )
            ## Clean up temporary files.
            file.remove(tarfile)
            unlink(exdir, recursive = TRUE)
        }
    )
    invisible(out)
}

#' Update R packages
#'
#' Handles CRAN removals and GitHub deprecations automatically.
#'
#' @note Updated 2020-08-09.
#' @noRd
updatePackages <- function() {
    requireNamespaces("bb8")
    suppressMessages({
        bb8::uninstall(
            pkgs = c(
                ## "Matrix.utils"
                "SDMTools",
                "bioverbs",
                "brio",
                "freerange",
                "lsei",
                "npsurv",
                "nvimcom",
                "pfgsea",
                "profdpm",
                "purrrogress",
                "robust",
                "transformer"
            )
        )
    })
    bb8::updatePackages()
}
