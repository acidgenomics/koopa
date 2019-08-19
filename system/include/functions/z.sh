#!/bin/sh
# shellcheck disable=SC2039



# Updated 2019-08-18.
_koopa_zsh_version() {
    zsh --version | \
        head -n 1 | \
        cut -d ' ' -f 2
        # > cut -d '.' -f 1-2
}
