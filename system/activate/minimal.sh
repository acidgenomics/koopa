#!/bin/sh



# Pre-flight checks                                                         {{{1
# ==============================================================================

# Operating system                                                          {{{2
# ------------------------------------------------------------------------------

# Bash sets the shell variable OSTYPE (e.g. linux-gnu).
# However, this doesn't work consistently with zsh, so use uname instead.

case "$(uname -s)" in
    Darwin)
        ;;
    Linux)
        ;;
    *)
        >&2 printf "Error: Unsupported operating system.\n"
        return 1
        ;;
esac

# Bad settings                                                              {{{2
# ------------------------------------------------------------------------------

# Note that we're skipping this checks inside RStudio shell.
if [ -z "${RSTUDIO:-}" ]
then
    _koopa_warn_if_export JAVA_HOME LD_LIBRARY_PATH PYTHONHOME R_HOME
fi



# XDG base directory specification                                          {{{1
# ==============================================================================

# XDG_RUNTIME_DIR:
# - Can only exist for the duration of the user's login.
# - Updated every 6 hours or set sticky bit if persistence is desired.
# - Should not store large files as it may be mounted as a tmpfs.

# > if [ ! -d "$XDG_RUNTIME_DIR" ]
# > then
# >     mkdir -pv "$XDG_RUNTIME_DIR"
# >     chown "$USER" "$XDG_RUNTIME_DIR"
# >     chmod 0700 "$XDG_RUNTIME_DIR"
# > fi

# See also:
# - https://developer.gnome.org/basedir-spec/
# - https://wiki.archlinux.org/index.php/XDG_Base_Directory

if [ -z "${XDG_CACHE_HOME:-}" ]
then
    XDG_CACHE_HOME="${HOME}/.cache"
fi

if [ -z "${XDG_CONFIG_HOME:-}" ]
then
    XDG_CONFIG_HOME="${HOME}/.config"
fi

if [ -z "${XDG_DATA_HOME:-}" ]
then
    XDG_DATA_HOME="${HOME}/.local/share"
fi

if [ -z "${XDG_RUNTIME_DIR:-}" ]
then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    if _koopa_is_macos
    then
        XDG_RUNTIME_DIR="/tmp${XDG_RUNTIME_DIR}"
    fi
fi

if [ -z "${XDG_DATA_DIRS:-}" ]
then
    XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

if [ -z "${XDG_CONFIG_DIRS:-}" ]
then
    XDG_CONFIG_DIRS="/etc/xdg"
fi

export XDG_CACHE_HOME
export XDG_CONFIG_DIRS
export XDG_CONFIG_HOME
export XDG_DATA_DIRS
export XDG_DATA_HOME
export XDG_RUNTIME_DIR

mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME"



# Standard globals                                                          {{{1
# ==============================================================================

# This variables are used by some koopa scripts, so ensure they're always
# consistently exported across platforms.

# HOSTNAME
if [ -z "${HOSTNAME:-}" ]
then
    HOSTNAME="$(uname -n)"
    export HOSTNAME
fi

# OSTYPE
# Automatically set by bash and zsh.
if [ -z "${OSTYPE:-}" ]
then
    OSTYPE="$(uname -s | tr '[:upper:]' '[:lower:]')"
    export OSTYPE
fi

# SHELL
# Note that this doesn't currently get set by RStudio terminal.
SHELL="$(_koopa_which_realpath "$KOOPA_SHELL")"
export SHELL

# TERM
# Terminal color mode. This should normally be set by the terminal client.
if [ -z "${TERM:-}" ]
then
    export TERM="screen-256color"
fi

# TMPDIR
if [ -z "${TMPDIR:-}" ]
then
    export TMPDIR="/tmp"
fi

# TODAY
# Current date. Alternatively, can use '%F' shorthand.
if [ -z "${TODAY:-}" ]
then
    TODAY="$(date +%Y-%m-%d)"
    export TODAY
fi

# USER
if [ -z "${USER:-}" ]
then
    USER="$(whoami)"
    export USER
fi



# CPU count                                                                 {{{1
# ==============================================================================

if [ -z "${CPU_COUNT:-}" ]
then
    CPU_COUNT="$(_koopa_cpu_count)"
    export CPU_COUNT
fi



# Path prefixes                                                             {{{1
# ==============================================================================

# Note that here we're making sure local binaries are included.
# Inspect '/etc/profile' if system PATH appears misconfigured.

# See also:
# - https://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard

# Standard Unix paths                                                       {{{2
# ------------------------------------------------------------------------------

_koopa_add_to_path_end "/usr/local/bin"
_koopa_add_to_path_end "/usr/bin"
_koopa_add_to_path_end "/bin"

_koopa_has_sudo && _koopa_add_to_path_end "/usr/local/sbin"
_koopa_has_sudo && _koopa_add_to_path_end "/usr/sbin"

# > _koopa_add_to_path_start "${HOME}/bin"
# > _koopa_add_to_path_start "${HOME}/local/bin"

# I think if XDG is configured correctly this gets added automatically.
_koopa_add_to_path_start "${HOME}/.local/bin"

_koopa_add_to_manpath_end "/usr/local/share/man"
_koopa_add_to_manpath_end "/usr/share/man"
_koopa_add_to_manpath_start "${HOME}/.local/share/man"

# Ruby gems.
_koopa_add_to_path_start "${HOME}/.gem/bin"

# Koopa paths                                                               {{{2
# ------------------------------------------------------------------------------

_koopa_activate_prefix "$KOOPA_PREFIX"
_koopa_activate_prefix "${KOOPA_PREFIX}/shell/${KOOPA_SHELL}"

if _koopa_is_linux
then
    _koopa_activate_prefix "${KOOPA_PREFIX}/os/linux"
    if _koopa_is_debian
    then
        _koopa_activate_prefix "${KOOPA_PREFIX}/os/debian"
    elif _koopa_is_fedora
    then
        _koopa_activate_prefix "${KOOPA_PREFIX}/os/fedora"
    fi

    if _koopa_is_rhel
    then
        _koopa_activate_prefix "${KOOPA_PREFIX}/os/rhel"
    fi
fi

_koopa_activate_prefix "${KOOPA_PREFIX}/os/$(_koopa_os_id)"
_koopa_activate_prefix "${KOOPA_PREFIX}/host/$(_koopa_host_id)"

# Private scripts                                                           {{{2
# ------------------------------------------------------------------------------

_koopa_activate_prefix "$(_koopa_config_prefix)/docker"
_koopa_activate_prefix "$(_koopa_config_prefix)/scripts-private"



# Activation functions                                                      {{{1
# ==============================================================================

_koopa_activate_pipx
