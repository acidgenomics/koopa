#!/usr/bin/env bash

koopa_install_git_filter_repo() {
    koopa_install_app \
        --installer='python-package' \
        --name='git-filter-repo' \
        "$@"
}
