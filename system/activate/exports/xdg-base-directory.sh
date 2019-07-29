#!/bin/sh

# XDG base directory specification.
# Updated 2019-07-27.

# See also:
# - https://developer.gnome.org/basedir-spec/
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory



# User directories                                                          {{{1
# ==============================================================================

if [ -z "${XDG_CACHE_HOME:-}" ]
then
    export XDG_CACHE_HOME="${HOME}/.cache"
fi

if [ -z "${XDG_CONFIG_HOME:-}" ]
then
    export XDG_CONFIG_HOME="${HOME}/.config"
fi

if [ -z "${XDG_DATA_HOME:-}" ]
then
    export XDG_DATA_HOME="${HOME}/.local/share"
fi

mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"

# XDG_RUNTIME_DIR
# - Can only exist for the duration of the user's login.
# - Updated every 6 hours or set sticky bit if persistence is desired.
# - Should not store large files as it may be mounted as a tmpfs.
if [ -z "${XDG_RUNTIME_DIR:-}" ]
then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    # Note that `/run` top level doesn't exist on macOS.
    _koopa_is_darwin && XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
    export XDG_RUNTIME_DIR
    # Include this if block, otherwise terminal in RStudio freaks out.
    # This is still freaking out inside RStudio terminal, so disabling.
    # > if [ ! -d "$XDG_RUNTIME_DIR" ]
    # > then
    # >     mkdir -p "$XDG_RUNTIME_DIR"
    # >     chown "$USER" "$XDG_RUNTIME_DIR"
    # >     chmod 0700 "$XDG_RUNTIME_DIR"
    # > fi
fi



# System directories                                                        {{{1
# ==============================================================================

if [ -z "${XDG_DATA_DIRS:-}" ]
then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# This directory currently isn't configured by default for macOS.
if [ -z "${XDG_CONFIG_DIRS:-}" ]
then
    export XDG_CONFIG_DIRS="/etc/xdg"
fi
