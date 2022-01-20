#!/usr/bin/env bash

# FIXME Rework using app/dict approach.
koopa::docker_tag() { # {{{1
    # """
    # Add Docker tag.
    # Updated 2021-10-25.
    # """
    local dest_tag docker image server source_tag
    koopa::assert_has_args "$#"
    docker="$(koopa::locate_docker)"
    image="${1:?}"
    source_tag="${2:?}"
    dest_tag="${3:-latest}"
    # Consider allowing this to be user-definable in a future update.
    server='docker.io'
    # Assume acidgenomics recipe by default.
    if ! koopa::str_detect_fixed "$image" '/'
    then
        image="acidgenomics/${image}"
    fi
    if [[ "$source_tag" == "$dest_tag" ]]
    then
        koopa::print "Source tag identical to destination ('${source_tag}')."
        return 0
    fi
    koopa::alert "Tagging '${image}:${source_tag}' as '${dest_tag}'."
    "$docker" login "$server"
    "$docker" pull "${server}/${image}:${source_tag}"
    "$docker" tag "${image}:${source_tag}" "${image}:${dest_tag}"
    "$docker" push "${server}/${image}:${dest_tag}"
    return 0
}
