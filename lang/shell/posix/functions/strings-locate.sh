#!/usr/bin/env bash

# FIXME Rename this to include 'locate_' for better consistency.

__koopa_gnu_app() { # {{{1
    # """
    # GNU app.
    # @note Updated 2021-05-21.
    # """
    local brew_name brew_prefix cmd
    [ "$#" -eq 2 ] || return 1
    brew_name="${1:?}"
    cmd="${2:?}"
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        case "$brew_name" in
            bc | \
            gzip)
                cmd="bin/${cmd}"
                ;;
            *)
                cmd="libexec/gnubin/${cmd}"
                ;;
        esac
        cmd="${brew_prefix}/opt/${brew_name}/${cmd}"
    fi
    [ -x "$cmd" ] || return 1
    _koopa_print "$cmd"
    return 0
}

# FIXME Standardize the Homebrew approach...
_koopa_locate_7z() { # {{{1
    # """
    # Locate 7z.
    # @note Updated 2021-05-21.
    # """
    local brew_prefix cmd
    cmd='7z'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        cmd="${brew_prefix}/opt/p7zip/bin/${cmd}"
    fi
    [ -x "$cmd" ] || return 1
    _koopa_print "$cmd"
    return 0
}

# FIXME Standardize the Homebrew approach...
_koopa_locate_bunzip2() { # {{{1
    # """
    # Locate bunzip2.
    # @note Updated 2021-05-21.
    # """
    local brew_prefix cmd
    cmd='bunzip2'
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        cmd="${brew_prefix}/opt/bzip2/bin/${cmd}"
    fi
    [ -x "$cmd" ] || return 1
    _koopa_print "$cmd"
    return 0
}

# FIXME Can we standardize the homebrew approach here a little better???
# See also approach for 7z and bunzip2, which is duplicated...
_koopa_locate_unzip() { # {{{1
    # """
    # Locate unzip.
    # @note Updated 2021-05-21.
    # """
    return 0
}





# FIXME Need to rename this...
# FIXME Return the full path...
_koopa_conda() { # {{{1
    # """
    # Which conda (or mamba) to use.
    # @note Updated 2021-05-14.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    local x
    x='conda'
    if _koopa_is_installed mamba
    then
        x='mamba'
    fi
    _koopa_print "$x"
    return 0
}


_koopa_gnu_awk() { # {{{1
    # """
    # GNU awk.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'gawk' 'awk' "$@"
    return 0
}

_koopa_gnu_basename() { # {{{1
    # """
    # GNU basename.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'basename' "$@"
    return 0
}

_koopa_gnu_bc() { # {{{1
    # """
    # GNU bc.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'bc' 'bc' "$@"
    return 0
}

_koopa_gnu_chgrp() { # {{{1
    # """
    # GNU chgrp.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'chgrp' "$@"
    return 0
}

_koopa_gnu_chmod() { # {{{1
    # """
    # GNU chmod.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'chmod' "$@"
    return 0
}

_koopa_gnu_chown() { # {{{1
    # """
    # GNU chown.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'chown' "$@"
    return 0
}

_koopa_gnu_cp() { # {{{1
    # """
    # GNU cp.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'cp' "$@"
    return 0
}

_koopa_gnu_cut() { # {{{1
    # """
    # GNU cut.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'cut' "$@"
    return 0
}

_koopa_gnu_date() { # {{{1
    # """
    # GNU date.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'date' "$@"
    return 0
}

_koopa_gnu_dirname() { # {{{1
    # """
    # GNU dirname.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'dirname' "$@"
    return 0
}

_koopa_gnu_du() { # {{{1
    # """
    # GNU du.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'du' "$@"
    return 0
}

_koopa_gnu_find() { # {{{1
    # """
    # GNU find.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'findutils' 'find' "$@"
    return 0
}

_koopa_gnu_grep() { # {{{1
    # """
    # GNU grep.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'grep' 'grep' "$@"
    return 0
}

_koopa_gnu_gunzip() { # {{{1
    __koopa_gnu_app 'gzip' 'gunzip' "$@"
}

_koopa_gnu_head() { # {{{1
    # """
    # GNU du.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'head' "$@"
    return 0
}

_koopa_gnu_ln() { # {{{1
    # """
    # GNU ls.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'ln' "$@"
    return 0
}

_koopa_gnu_ls() { # {{{1
    # """
    # GNU ls.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'ls' "$@"
    return 0
}

_koopa_gnu_make() { # {{{1
    # """
    # GNU make.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'make' 'make' "$@"
    return 0
}

_koopa_gnu_man() { # {{{1
    # """
    # GNU man-db.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'man-db' 'man' "$@"
    return 0
}

_koopa_gnu_mkdir() { # {{{1
    # """
    # GNU mkdir.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'mkdir' "$@"
    return 0
}

_koopa_gnu_mv() { # {{{1
    # """
    # GNU mv.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'mv' "$@"
    return 0
}

_koopa_gnu_readlink() { # {{{1
    # """
    # GNU readlink.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'readlink' "$@"
    return 0
}

_koopa_gnu_realpath() { # {{{1
    # """
    # GNU realpath.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'realpath' "$@"
    return 0
}

_koopa_gnu_rm() { # {{{1
    # """
    # GNU rm.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'rm' "$@"
    return 0
}

_koopa_gnu_sed() { # {{{1
    # """
    # GNU sed.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'gnu-sed' 'sed' "$@"
    return 0
}

_koopa_gnu_sort() { # {{{1
    # """
    # GNU sort.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'sort' "$@"
    return 0
}

_koopa_gnu_stat() { # {{{1
    # """
    # GNU stat.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'stat' "$@"
    return 0
}

_koopa_gnu_tail() { # {{{1
    # """
    # GNU tail.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'tail' "$@"
    return 0
}

_koopa_gnu_tar() { # {{{1
    # """
    # GNU tar.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'gnu-tar' 'tar' "$@"
    return 0
}

_koopa_gnu_tee() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'tee' "$@"
    return 0
}

_koopa_gnu_tr() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'tr' "$@"
    return 0
}

_koopa_gnu_uncompress() { # {{{1
    __koopa_gnu_app 'gzip' 'uncompress' "$@"
}

_koopa_gnu_uname() { # {{{1
    # """
    # GNU uname.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'uname' "$@"
    return 0
}

_koopa_gnu_wc() { # {{{1
    # """
    # GNU wc.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'wc' "$@"
    return 0
}

_koopa_gnu_xargs() { # {{{1
    # """
    # GNU xargs.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'findutils' 'xargs' "$@"
    return 0
}

# FIXME Rename with locate...
_koopa_python() { # {{{1
    # """
    # Python executable path.
    # @note Updated 2021-05-21.
    # """
    local x
    x='python3'
    x="$(_koopa_which "$x")"
    [ -x "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

# FIXME Rename with locate...
_koopa_r() { # {{{1
    # """
    # R executable path.
    # @note Updated 2021-05-21.
    # """
    local x
    x='R'
    x="$(_koopa_which "$x")"
    [ -x "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_locate_shell() { # {{{1
    # """
    # Locate the current shell executable.
    # @note Updated 2021-05-20.
    #
    # Detection issues with qemu ARM emulation on x86:
    # - The 'ps' approach will return correct shell for ARM running via
    #   emulation on x86 (e.g. Docker).
    # - ARM running via emulation on x86 (e.g. Docker) will return
    #   '/usr/bin/qemu-aarch64' here, rather than the shell we want.
    #
    # Useful variables:
    # - Bash: 'BASH_VERSION'
    # - Zsh: 'ZSH_VERSION'
    #
    # When '/proc' exists:
    # - Shell invocation:
    #   > cat "/proc/${$}/cmdline"
    #   ## bash-il
    # - Shell path:
    #   > readlink "/proc/${$}/exe"
    #   ## /usr/bin/bash
    #
    # How to resolve shell name when ps is installed:
    # > shell_name="$( \
    # >     ps -p "${$}" -o 'comm=' \
    # >     | sed 's/^-//' \
    # > )"
    #
    # @seealso
    # - https://stackoverflow.com/questions/3327013
    # - http://opensourceforgeeks.blogspot.com/2013/05/
    #     how-to-find-current-shell-in-linux.html
    # - https://superuser.com/questions/103309/
    # - https://unix.stackexchange.com/questions/87061/
    # - https://unix.stackexchange.com/questions/182590/
    # """
    local str
    str=''
    if [ -n "${KOOPA_SHELL:-}" ]
    then
        str="$KOOPA_SHELL"
    elif _koopa_is_linux
    then
        # FIXME The proc approach returns the full path.
        # This errors in Docker because it returns qemu...but it should NOT
        # be the default. We need to use this as a fallback in case system
        # is Docker...
        if _koopa_is_installed ps sed
        then
            str="$( \
                ps -p "${$}" -o 'comm=' \
                | sed 's/^-//' \
            )"
        elif [ -x "/proc/${$}/exe" ]
        then
            str="$(_koopa_realpath "/proc/${$}/exe")"
        fi
    elif _koopa_is_macos
    then
        if _koopa_is_installed lsof sed
        then
            str="$( \
                lsof \
                    -a \
                    -F 'n' \
                    -d 'txt' \
                    -p "${$}" \
                | sed -n '3p' \
                | sed 's/^n//' \
            )"
        fi
    fi
    [ -n "$str" ] || return 1
    _koopa_print "$str"
    return 0
}
