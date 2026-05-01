#!/usr/bin/env bash

_koopa_install_git_filter_repo() {
    _koopa_install_app \
        --installer='python-package' \
        --name='git-filter-repo' \
        "$@"
}
