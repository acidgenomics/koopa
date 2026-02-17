#!/usr/bin/env bash
set -Eeuo pipefail

install_venv() {
    if [[ ! -d '.venv' ]]
    then
        local python_version
        [[ -f '.python-version' ]] || return 1
        IFS= read -r python_version < '.python-version'
        uv venv .venv \
            --no-python-downloads \
            --python "$python_version"
    fi
    # shellcheck source=/dev/null
    source '.venv/bin/activate'
    rm -f uv.lock
    uv pip install \
        --all-extras \
        --editable . \
        --only-binary=':all:' \
        --requirements 'pyproject.toml' \
        --upgrade
    uv lock
    uv pip compile 'pyproject.toml' \
        --output-file 'requirements.txt' \
        > /dev/null
    uv pip list
    return 0
}

main() {
    local -a cache_dirs
    if ! command -v 'uv' &> /dev/null
    then
        echo 'uv is required.'
        return 1
    fi
    cache_dirs=(
        'build'
        'lang/python/src/koopa.egg-info'
    )
    rm -fr "${cache_dirs[@]}"
    install_venv
    rm -fr "${cache_dirs[@]}"
    return 0
}

main "$@"
