#!/usr/bin/env bash

# FIXME Consider making these accessible only in Bash scripts, to
# ensure that POSIX activation stays fast.

__koopa_locate_app() { # {{{1
    # """
    # Locate file system path to an application.
    # @note Updated 2021-05-24.
    # """
    local app_name brew_name brew_prefix file
    [ "$#" -eq 2 ] || return 1
    brew_name="${1:?}"
    app_name="${2:?}"
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        file="${brew_prefix}/opt/${brew_name}/bin/${app_name}"
        [ -x "$file" ] || return 1
        _koopa_print "$file"
    else
        _koopa_print "$app_name"
    fi
    return 0
}

__koopa_locate_app_simple() { # {{{1
    # """
    # Simpler app location fetcher that doesn't attempt to use Homebrew.
    # @note Updated 2021-05-24.
    # """
    local app_name file
    [ "$#" -eq 1 ] || return 1
    app_name="${1:?}"
    file="$(_koopa_which_realpath "$app_name")"
    [ -x "$file" ] || return 1
    _koopa_print "$file"
    return 0
}

__koopa_locate_gnu_app() { # {{{1
    # """
    # Locate a GNU application.
    # @note Updated 2021-05-24.
    # """
    local app_name brew_name brew_prefix file
    [ "$#" -eq 2 ] || return 1
    brew_name="${1:?}"
    app_name="${2:?}"
    if _koopa_is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        file="${brew_prefix}/opt/${brew_name}/libexec/gnubin/${app_name}"
        [ -x "$file" ] || return 1
        _koopa_print "$file"
    else
        _koopa_print "$app_name"
    fi
    return 0
}

_koopa_locate_7z() { # {{{1
    # """
    # Locate 7z.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'p7zip' '7z' "$@"
}

_koopa_locate_awk() { # {{{1
    # """
    # Locate GNU awk.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'gawk' 'awk' "$@"
}

_koopa_locate_basename() { # {{{1
    # """
    # Locate GNU basename.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'basename' "$@"
}

_koopa_locate_bc() { # {{{1
    # """
    # Locate GNU bc.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'bc' 'bc' "$@"
}

_koopa_locate_bunzip2() { # {{{1
    # """
    # Locate bunzip2.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'bzip2' 'bunzip2'
}

_koopa_locate_chgrp() { # {{{1
    # """
    # Locate GNU chgrp.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'chgrp' "$@"
}

_koopa_locate_chmod() { # {{{1
    # """
    # Locate GNU chmod.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'chmod' "$@"
}

_koopa_locate_chown() { # {{{1
    # """
    # Locate GNU chown.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'chown' "$@"
}

_koopa_locate_conda() { # {{{1
    # """
    # Locate conda (or mamba).
    # @note Updated 2021-05-21.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    [ "$#" -eq 0 ] || return 1
    if _koopa_is_installed 'mamba'
    then
        x='mamba'
    else
        x='conda'
    fi
    _koopa_print "$x"
    return 0
}

_koopa_locate_cp() { # {{{1
    # """
    # Locate GNU cp.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'cp' "$@"
}

_koopa_locate_curl() { # {{{1
    # """
    # Locate curl.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'curl' 'curl' "$@"
}

_koopa_locate_cut() { # {{{1
    # """
    # Locate GNU cut.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'cut' "$@"
}

_koopa_locate_date() { # {{{1
    # """
    # Locate GNU date.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'date' "$@"
}

_koopa_locate_df() { # {{{1
    # """
    # Locate GNU df.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'df' "$@"
}

_koopa_locate_dirname() { # {{{1
    # """
    # Locate GNU dirname.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'dirname' "$@"
}

_koopa_locate_du() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'du' "$@"
}

_koopa_locate_find() { # {{{1
    # """
    # Locate GNU find.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'findutils' 'find' "$@"
}

_koopa_locate_gcc() { # {{{1
    # """
    # Locate GNU gcc.
    # @note Updated 2021-05-24.
    # """
    local version
    version="$(_koopa_variable 'gcc')"
    version="$(_koopa_major_version "$version")"
    __koopa_locate_app "gcc@${version}" "gcc-${version}" "$@"
}

_koopa_locate_grep() { # {{{1
    # """
    # Locate GNU grep.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'grep' 'grep' "$@"
}

_koopa_locate_gunzip() { # {{{1
    # """
    # Locate GNU gunzip.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'gzip' 'gunzip' "$@"
}

_koopa_locate_head() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'head' "$@"
}

_koopa_locate_id() { # {{{1
    # """
    # Locate GNU id.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'id' "$@"
}

_koopa_locate_llvm_config() { # {{{1
    # """
    # Locate 'llvm-config' executable.
    # @note Updated 2021-05-24.
    #
    # This is versioned on many Linux systems.
    # """
    local brew_prefix find sort tail x
    x="${LLVM_CONFIG:-}"
    if [ -z "$x" ]
    then
        if _koopa_is_linux
        then
            find="$(_koopa_locate_find)"
            sort="$(_koopa_locate_sort)"
            tail="$(_koopa_locate_tail)"
            x="$( \
                "$find" '/usr/bin' -name 'llvm-config-*' \
                | "$sort" \
                | "$tail" -n 1 \
            )"
        elif _koopa_is_macos
        then
            brew_prefix="$(_koopa_homebrew_prefix)"
            x="${brew_prefix}/opt/llvm/bin/llvm-config"
        fi
    fi
    [ -x "$x" ] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_locate_ln() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'ln' "$@"
}

_koopa_locate_ls() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'ls' "$@"
}

_koopa_locate_make() { # {{{1
    # """
    # Locate GNU make.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'make' 'make' "$@"
}

_koopa_locate_man() { # {{{1
    # """
    # Locate GNU man-db.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'man-db' 'man' "$@"
}

_koopa_locate_mkdir() { # {{{1
    # """
    # Locate GNU mkdir.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'mkdir' "$@"
}

_koopa_locate_mktemp() { # {{{1
    # """
    # Locate GNU mktemp.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'mktemp' "$@"
}

_koopa_locate_mv() { # {{{1
    # """
    # Locate GNU mv.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'mv' "$@"
}

_koopa_locate_paste() { # {{{1
    # """
    # Locate GNU paste.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'paste' "$@"
}

_koopa_locate_patch() { # {{{1
    # """
    # Locate GNU patch.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'gpatch' 'patch' "$@"
}

_koopa_locate_parallel() { # {{{1
    # """
    # Locate GNU parallel.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'parallel' 'parallel' "$@"
}

_koopa_locate_pcregrep() { # {{{1
    # """
    # Locate pcregrep.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'pcre' 'pcregrep' "$@"
}

_koopa_locate_pkg_config() { # {{{1
    # """
    # Locate pkg-config.
    # @note Updated 2021-05-24.
    # """
    __koopa_locate_app 'pkg-config' 'pkg-config' "$@"
}

# FIXME Need to replace in other functions.
_koopa_locate_python() { # {{{1
    # """
    # Locate Python.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app_simple 'python3'
}

# FIXME Need to replace in other functions.
_koopa_locate_r() { # {{{1
    # """
    # Locate R.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app_simple 'R'
}

_koopa_locate_readlink() { # {{{1
    # """
    # Locate GNU readlink.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'readlink' "$@"
}

_koopa_locate_realpath() { # {{{1
    # """
    # Locate GNU realpath.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'realpath' "$@"
}

_koopa_locate_rename() { # {{{1
    # """
    # Locate Perl rename.
    # @note Updated 2021-05-24.
    # """
    local file prefix
    prefix="$(_koopa_perl_packages_prefix)"
    file="${prefix}/bin/rename"
    [[ -x "$file" ]] || return 1
    __koopa_print "$file"
    return 0
}

_koopa_locate_rm() { # {{{1
    # """
    # Locate GNU rm.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'rm' "$@"
}

_koopa_locate_rsync() { # {{{1
    # """
    # Locate rsync.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'rsync' 'rsync' "$@"
}

_koopa_locate_sed() { # {{{1
    # """
    # Locate GNU sed.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'gnu-sed' 'sed' "$@"
}

_koopa_locate_shell() { # {{{1
    # """
    # Locate the current shell executable.
    # @note Updated 2021-05-21.
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
    local proc_file pid ps sed shell
    shell="${KOOPA_SHELL:-}"
    if [ -x "$shell" ]
    then
        _koopa_print "$shell"
        return 0
    fi
    pid="${$}"
    sed="$(_koopa_locate_sed)"
    if _koopa_is_linux
    then
        proc_file="/proc/${pid}/exe"
        if [ -x "$proc_file" ] && ! _koopa_is_docker
        then
            shell="$(_koopa_realpath "$proc_file")"
        elif _koopa_is_installed ps sed
        then
            ps="$(_koopa_locate_ps)"  # FIXME Need to add this.
            shell="$( \
                "$ps" -p "$pid" -o 'comm=' \
                | "$sed" 's/^-//' \
            )"
            shell="$(_koopa_which_realpath "$shell")"
        fi
    elif _koopa_is_macos
    then
        if _koopa_is_installed lsof sed
        then
            shell="$( \
                lsof \
                    -a \
                    -F 'n' \
                    -d 'txt' \
                    -p "$pid" \
                | "$sed" -n '3p' \
                | "$sed" 's/^n//' \
            )"
        fi
    fi
    [ -x "$shell" ] || return 1
    _koopa_print "$shell"
    return 0
}

_koopa_locate_sort() { # {{{1
    # """
    # Locate GNU sort.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'sort' "$@"
}

_koopa_locate_ssh() { # {{{1
    # """
    # Locate ssh.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'openssh' 'ssh' "$@"
}

_koopa_locate_stat() { # {{{1
    # """
    # Locate GNU stat.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'stat' "$@"
}

_koopa_locate_tac() { # {{{1
    # """
    # Locate GNU tac.
    # @note Updated 2021-05-24.
    # """
    __koopa_locate_gnu_app 'coreutils' 'tac' "$@"
}

_koopa_locate_tail() { # {{{1
    # """
    # Locate GNU tail.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'tail' "$@"
}

_koopa_locate_tar() { # {{{1
    # """
    # Locate GNU tar.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'gnu-tar' 'tar' "$@"
}

_koopa_locate_tee() { # {{{1
    # """
    # Locate GNU tee.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'tee' "$@"
}

_koopa_locate_tr() { # {{{1
    # """
    # Locate GNU tr.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'tr' "$@"
}

_koopa_locate_uncompress() { # {{{1
    # """
    # Locate GNU uncompress.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'gzip' 'uncompress' "$@"
}

_koopa_locate_uname() { # {{{1
    # """
    # Locate GNU uname.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'uname' "$@"
}

_koopa_locate_uniq() { # {{{1
    # """
    # Locate GNU uniq.
    # @note Updated 2021-05-24.
    # """
    __koopa_locate_gnu_app 'coreutils' 'uniq' "$@"
}

_koopa_locate_unzip() { # {{{1
    # """
    # Locate unzip.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'unzip' 'unzip'
}

_koopa_locate_wc() { # {{{1
    # """
    # Locate GNU wc.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'coreutils' 'wc' "$@"
}

_koopa_locate_wget() { # {{{1
    # """
    # Locate wget.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_app 'wget' 'wget' "$@"
}

_koopa_locate_xargs() { # {{{1
    # """
    # Locate GNU xargs.
    # @note Updated 2021-05-21.
    # """
    __koopa_locate_gnu_app 'findutils' 'xargs' "$@"
}
