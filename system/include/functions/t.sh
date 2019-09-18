#!/bin/sh
# shellcheck disable=SC2039



# Create temporary directory.
#
# Note: macOS requires `env LC_CTYPE=C`.
# Otherwise, you'll see this error: `tr: Illegal byte sequence`.
# This doesn't seem to work reliably, so using timestamp instead.
#
# See also:
# - https://gist.github.com/earthgecko/3089509
#
# Updated 2019-09-04.
_koopa_tmp_dir() {
    local unique
    local dir
    unique="$(date "+%Y%m%d-%H%M%S")"
    dir="/tmp/koopa-$(id -u)-${unique}"
    # This doesn't work well with zsh.
    # > mkdir -p "$dir"
    # > chown "$USER" "$dir"
    # > chmod 0775 "$dir"
    echo "$dir"
}



# Create a dated file today bucket.
# Also adds a `~/today` symlink for quick access.
#
# How to check if a symlink target matches a specific path:
# https://stackoverflow.com/questions/19860345
#
# Updated 2019-09-18.
_koopa_today_bucket() {
    bucket_dir="${HOME}/bucket"
    # Early return if there's no bucket directory on the system.
    if [[ ! -d "$bucket_dir" ]]
    then
        return 0
    fi
    today="$(date +%Y-%m-%d)"
    today_dir="${HOME}/today"
    # Early return if we've already updated the symlink.
    if readlink "$today_dir" | grep -q "$today"
    then
        return 0
    fi
    bucket_today="$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d)"
    mkdir -p "${bucket_dir}/${bucket_today}"
    # Note the use of `-n` flag here.
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    ln -fns "${bucket_dir}/${bucket_today}" "$today_dir"
}

