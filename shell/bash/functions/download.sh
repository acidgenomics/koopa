#!/usr/bin/env bash

koopa::download() { # {{{1
    # """
    # Download a file.
    # @note Updated 2020-07-05.
    #
    # Potentially useful curl flags:
    # * --connect-timeout <seconds>
    # * --silent
    # * --stderr
    # * --verbose
    #
    # Note that '--fail-early' flag is useful, but not supported on old versions
    # of curl (e.g. 7.29.0; RHEL 7).
    #
    # Alternatively, can use wget instead of curl:
    # > wget -O file url
    # > wget -q -O - url (piped to stdout)
    # > wget -qO-
    # """
    local bn file url wd
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl
    url="${1:?}"
    file="${2:-}"
    if [[ -z "$file" ]]
    then
        wd="$(pwd)"
        bn="$(basename "$url")"
        file="${wd}/${bn}"
    fi
    file="$(realpath "$file")"
    koopa::info "Downloading '${url}' to '${file}'."
    curl \
        --create-dirs \
        --fail \
        --location \
        --output "$file" \
        --progress-bar \
        --retry 5 \
        --show-error \
        "$url"
    return 0
}

koopa::download_cran_latest() {
    # """
    # Download CRAN latest.
    # @note Updated 2020-07-11.
    # """
    local name pattern url
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl grep head
    for name in "$@"
    do
        url="https://cran.r-project.org/web/packages/${name}/"
        pattern="${name}_[.0-9]+.tar.gz"
        file="$(curl --silent "$url" | grep -Eo "$pattern" | head -n 1)"
        koopa::download "https://cran.r-project.org/src/contrib/${file}"
    done
    return 0
}

