#!/usr/bin/env bash

koopa_locate_docker() {
    local -a args
    args=()
    if koopa_is_macos
    then
        args+=("${HOME:?}/.docker/bin/docker")
    else
        args+=('/usr/bin/docker')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
