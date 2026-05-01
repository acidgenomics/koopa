#!/usr/bin/env bash

_koopa_locate_docker() {
    local -a args
    args=()
    if _koopa_is_macos
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
    _koopa_locate_app "${args[@]}" "$@"
}
