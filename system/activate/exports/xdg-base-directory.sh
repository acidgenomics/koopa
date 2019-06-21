#!/bin/sh

# XDG base directory specification.
# Modified 2019-06-17.

# See also:
# - https://developer.gnome.org/basedir-spec/
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory



# User directories                                                          {{{1
# ==============================================================================

[ -z "${XDG_CACHE_HOME:-}" ] && \
    export XDG_CACHE_HOME="${HOME}/.cache"
[ -z "${XDG_CONFIG_HOME:-}" ] && \
    export XDG_CONFIG_HOME="${HOME}/.config"
[ -z "${XDG_DATA_HOME:-}" ] && \
    export XDG_DATA_HOME="${HOME}/.local/share"

mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

# XDG_RUNTIME_DIR
# - Can only exist for the duration of the user's login.
# - Modified every 6 hours or set sticky bit if persistence is desired.
# - Should not store large files as it may be mounted as a tmpfs.
if [ -z "${XDG_RUNTIME_DIR:-}" ]
then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    # Note that `/run` top level doesn't exist on macOS.
    [ ! -z "${MACOS:-}" ] && XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
    export XDG_RUNTIME_DIR
    mkdir -p "$XDG_RUNTIME_DIR"
    chown "$USER" "$XDG_RUNTIME_DIR"
    chmod 0700 "$XDG_RUNTIME_DIR"
fi



# System directories                                                        {{{1
# ==============================================================================

[ -z "${XDG_DATA_DIRS:-}" ] && \
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"

# This directory currently isn't configured by default for macOS.
[ -z "${XDG_CONFIG_DIRS:-}" ] && \
    export XDG_CONFIG_DIRS="/etc/xdg"
