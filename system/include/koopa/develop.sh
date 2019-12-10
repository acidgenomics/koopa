#!/usr/bin/env bash
set -Eeu -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

koopa_prefix="$(_koopa_prefix)"
_koopa_message "Switching koopa to develop branch at '${koopa_prefix}'."

(
    cd "$koopa_prefix" || exit 1
    git checkout master
    git fetch --all
    git pull
    git branch -Dq develop
    git checkout -b develop origin/develop
    git remote set-url origin git@github.com:acidgenomics/koopa.git
    git remote -v
)

_koopa_success "Developer mode is enabled."
