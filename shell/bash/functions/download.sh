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
    koopa::assert_has_args "$#"
    koopa::assert_is_installed curl
    local bn file url wd
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

