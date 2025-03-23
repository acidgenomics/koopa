#!/usr/bin/env bash

koopa_locate_docker() {
    local -a args
    args=()
    if koopa_is_macos
    then
        # Support new 'user' setting. Otherwise default to 'system' setting.
        if [[ -x "${HOME:?}/.docker/bin/docker" ]]
        then
            args+=("${HOME:?}/.docker/bin/docker")
        else
            args+=('/usr/local/bin/docker')
        fi
    else
        args+=('/usr/bin/docker')
    fi
    koopa_locate_app "${args[@]}" "$@"
}
