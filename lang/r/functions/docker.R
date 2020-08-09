#' Build all tags for a specific image
#' @note Updated 2020-08-09.
#' @noRd
dockerBuildAllTags <- function() {
    days <- 2L
    dockerDir <- file.path("~", ".config", "koopa", "docker")
    args <- parseArgs(
        optionalArgs = c("days", "dir"),
        flags = "force",
        positional = TRUE
    )
    force <- "force" %in% args[["flags"]]
    optionalArgs <- args[["optionalArgs"]]
    if (!is.null(optionalArgs)) {
        if (isSubset("days", names(optionalArgs))) {
            days <- as.numeric(optionalArgs[["days"]])
        }
        if (isSubset("dir", names(optionalArgs))) {
            dockerDir <- optionalArgs[["dir"]]
        }
    }
    assert(
        isNumber(days),
        isADir(dockerDir),
        isFlag(force)
    )
    images <- args[["positionalArgs"]]
    if (!any(grepl(pattern = "/", x = images)))
        images <- file.path("acidgenomics", images)
    message(sprintf("Building all tags: %s", toString(images)))
    invisible(lapply(
        X = images,
        FUN = function(image) {
            imageDir <- file.path(dockerDir, image)
            assert(
                is.character(image),
                dir.exists(imageDir)
            )
            ## Build tags in desired order, using "build.txt" file.
            buildFile <- file.path(imageDir, "build.txt")
            if (file.exists(buildFile)) {
                tags <- readLines(buildFile)
            } else {
                ## Or build alphabetically (default).
                tags <- sort(list.dirs(
                    path = imageDir,
                    full.names = FALSE,
                    recursive = FALSE
                ))
            }
            if (length(tags) > 1L) {
                ## Build "latest" tag automatically at the end.
                tags <- setdiff(tags, "latest")
            }
            assert(hasLength(tags))
            ## Build the versioned images, defined by `Dockerfile` in the
            ## subdirectories.
            status <- mapply(
                tag = tags,
                MoreArgs = list(image = image),
                FUN = function(image, tag) {
                    path <- file.path(imageDir, tag)
                    if (isSymlink(path)) {
                        sourceTag <- basename(realpath(path))
                        destTag <- tag
                        shell(
                            command = file.path(
                                koopaPrefix,
                                "bin",
                                "docker-tag"
                            ),
                            args = c(image, sourceTag, destTag)
                        )
                    } else {
                        if (!isTRUE(force)) {
                            if (isTRUE(
                                isDockerBuildRecent(image, days = days)
                            )) {
                                message(sprintf(
                                    "'%s:%s' was built recently. Skipping.",
                                    image, tag
                                ))
                                return(0L)
                            }
                        }
                        shell(
                            command = file.path(
                                koopaPrefix,
                                "bin",
                                "docker-build"
                            ),
                            args = c(
                                paste0("--tag=", tag),
                                image
                            )
                        )
                    }
                },
                USE.NAMES = FALSE,
                SIMPLIFY = TRUE
            )
            assert(all(as.integer(status) == 0L))
            ## Update "latest" tag, if necessary.
            latestFile <- file.path(imageDir, "latest")
            if (isAFile(latestFile) || isASymlink(latestFile)) {
                if (isASymlink(latestFile)) {
                    sourceTag <- basename(realpath(latestFile))
                } else if (isAFile(latestFile)) {
                    sourceTag <- readLines(latestFile)
                }
                assert(isString(sourceTag))
                destTag <- "latest"
                print(sprintf(
                    "Tagging %s '%s' as '%s'.",
                    image, sourceTag, destTag
                ))
                shell(
                    command = file.path(koopaPrefix, "bin", "docker-tag"),
                    args = c(image, sourceTag, destTag)
                )
            }
        }
    ))
}

#' Has the requested Docker image been built recently?
#' @note Updated 2020-08-07.
#' @noRd
isDockerBuildRecent <- function(image, days = 2L) {
    shell(
        command = "docker",
        args = c("pull", image),
        stdout = FALSE,
        stderr = FALSE
    )
    x <- shell(
        command = "docker",
        args = c(
            "inspect",
            "--format='{{json .Created}}'",
            image
        ),
        stdout = TRUE
    )
    x <- gsub("\"", "", x)
    x <- sub("\\.[0-9]+Z$", "", x)
    diffDays <- difftime(
        time1 = Sys.time(),
        time2 = as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%S"),
        units = "days"
    )
    diffDays < days
}
