#!/bin/sh
# shellcheck disable=SC2039



# Create temporary directory.
# # Note: macOS requires `env LC_CTYPE=C`.
# Otherwise, you'll see this error: `tr: Illegal byte sequence`.
# This doesn't seem to work reliably, so using timestamp instead.
# # See also:
# - https://gist.github.com/earthgecko/3089509
# # Updated 2019-06-27.
_koopa_tmp_dir() {
    local unique
    local dir

    unique="$(date "+%Y%m%d-%H%M%S")"
    dir="/tmp/koopa-$(id -u)-${unique}"

    mkdir -p "$dir"
    chown "$USER" "$dir"
    chmod 0775 "$dir"

    echo "$dir"
}
