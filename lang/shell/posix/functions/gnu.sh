#!/usr/bin/env bash

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
            bc)
                cmd="bin/${cmd}"
                ;;
            *)
                # Alternatively, can use:
                # > cmd="libexec/gnubin/${cmd}"
                cmd="bin/g${cmd}"
                ;;
        esac
    fi
    cmd="${brew_prefix}/opt/${brew_name}/${cmd}"
    if [ ! -x "$cmd" ]
    then
        _koopa_warning "Missing GNU app: '${cmd}'."
        return 1
    fi
    _koopa_print "$cmd"
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
