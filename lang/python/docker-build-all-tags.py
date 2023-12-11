#!/usr/bin/env python3

"""
Build all Docker tags.
Updated 2023-12-11.
"""

from argparse import ArgumentParser
from os.path import isdir
from sys import version_info

parser = ArgumentParser()
parser.add_argument("--local", required=True)
parser.add_argument("--remote", required=True)
args = parser.parse_args()


"""
FIXME Need to port this code from R.

#' Is the Docker build recent?
#'
#' @export
#' @note Updated 2023-03-16.
#'
#' @param image `character`.
#' Docker image name (e.g. `repo/image`).
#' Parameterized, supporting multiple image checks in a single call.
#'
#' @param days `integer(1)`.
#' Maximum number of days to consider build recent.
#'
#' @return `logical`.
#'
#' @examples
#' ## > image <- "public.ecr.aws/acidgenomics/koopa:debian"
#' ## > isDockerBuildRecent(image)
isDockerBuildRecent <- function(image, days = 2L) {
    assert(
        isDockerEnabled(),
        isCharacter(image),
        isNumber(days)
    )
    bapply(
        X = image,
        FUN = function(image) {
            ok <- tryCatch(
                expr = {
                    shell(
                        command = "docker",
                        args = c("pull", image),
                        print = FALSE
                    )
                    TRUE
                },
                error = function(e) {
                    FALSE
                }
            )
            if (isFALSE(ok)) {
                return(FALSE)
            }
            x <- tryCatch(
                expr = {
                    shell(
                        command = "docker",
                        args = c(
                            "inspect",
                            "--format='{{json .Created}}'",
                            image
                        ),
                        print = FALSE
                    )
                },
                error = function(e) {
                    FALSE
                }
            )
            if (isFALSE(x)) {
                return(FALSE)
            }
            assert(
                is.list(x),
                isSubset("stdout", names(x))
            )
            x <- x[["stdout"]]
            x <- sub(pattern = "\n$", replacement = "", x = x)
            ## e.g. "'\"2021-07-12T16:19:01.734591265Z\"'".
            x <- sub(pattern = "^'\"(.+)\"'$", replacement = "\\1", x = x)
            ## e.g. "2021-07-12T16:19:01.734591265Z".
            x <- sub(pattern = "\\.[0-9]+Z$", replacement = "", x = x)
            ## e.g. "2021-07-12T16:19:01".
            diffDays <- difftime(
                time1 = Sys.time(),
                time2 = as.POSIXct(x, format = "%Y-%m-%dT%H:%M:%S"),
                units = "days"
            )
            diffDays < days
        },
        USE.NAMES = TRUE
    )
}

#' Build all Docker tags
#'
#' @export
#' @note Updated 2023-03-28.
#'
#' @param local `character(1)`.
#' Docker image repository directory.
#'
#' @param remote `character(1)`.
#' Remote Docker image repository URL (e.g. ECR or DockerHub).
#'
#' @param days `numeric(1)`.
#' Number of days to allow since last build.
#'
#' @param force `logical(1)`.
#' Force rebuild.
#'
#' @return Invisible `logical(1)`.
#'
#' @examples
#' ## > local <- file.path(
#' ## >     "~",
#' ## >     "monorepo",
#' ## >     "docker",
#' ## >     "acidgenomics",
#' ## >     "koopa"
#' ## > )
#' ## > remote <- "public.ecr.aws/acidgenomics/koopa"
#' ## > dockerBuildAllTags(local = local, remote = remote)
dockerBuildAllTags <-
    function(local,
             remote,
             days = 2L,
             force = FALSE) {
        assert(
            isADir(local),
            isString(remote),
            isNumber(days),
            isFlag(force)
        )
        alert(sprintf("Building all tags: {.var %s}.", remote))
        ## Build tags in desired order, using "build.txt" file.
        buildFile <- file.path(local, "build.txt")
        if (file.exists(buildFile)) {
            tags <- readLines(buildFile)
            ## Ensure we ignore comments here.
            keep <- grepl(pattern = "^[a-z0-9_.-]+$", x = tags)
            tags <- tags[keep]
            assert(isCharacter(tags))
        } else {
            ## Or build alphabetically (default).
            tags <- sort(list.dirs(
                path = local,
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
        invisible(Map(
            tag = tags,
            MoreArgs = list(
                "local" = local,
                "remote" = remote
            ),
            f = function(tag, local, remote) {
                local <- file.path(local, tag)
                remote <- paste0(remote, ":", tag)
                alert(sprintf(
                    fmt = paste(
                        "Building {.var %s} at {.path %s}."
                    ),
                    remote, local
                ))
                if (isFALSE(force)) {
                    if (isTRUE(
                        tryCatch(
                            expr = {
                                isDockerBuildRecent(
                                    image = remote,
                                    days = days
                                )
                            },
                            error = function(e) {
                                FALSE
                            }
                        )
                    )) {
                        alertInfo(sprintf(
                            "{.var %s} was built recently.",
                            remote
                        ))
                        return(TRUE)
                    }
                }
                shell(
                    command = koopa(),
                    args = c(
                        "app", "docker", "build",
                        "--local", local,
                        "--remote", remote
                    ),
                    print = TRUE
                )
            }
        ))
        invisible(TRUE)
    }
"""


def main(local: str, remote: str) -> bool:
    """
    Build all Docker images.
    Updated 2023-12-11.
    """
    assert isdir(local)
    return True


if __name__ == "__main__":
    if not version_info >= (3, 6):
        raise RuntimeError("Unsupported Python version.")
    main(local=args.local, remote=args.remote)
