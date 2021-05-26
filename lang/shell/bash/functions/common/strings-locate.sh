#!/usr/bin/env bash

koopa:::locate_app() { # {{{1
    # """
    # Locate file system path to an application.
    # @note Updated 2021-05-25.
    # """
    local app_name brew_name brew_prefix file
    koopa::assert_has_args_eq "$#" 2
    brew_name="${1:?}"
    app_name="${2:?}"
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        file="${brew_prefix}/opt/${brew_name}/bin/${app_name}"
        koopa::assert_is_executable "$file"
        koopa::print "$file"
    else
        koopa::print "$app_name"
    fi
    return 0
}

koopa:::locate_app_simple() { # {{{1
    # """
    # Simpler app location fetcher that doesn't attempt to use Homebrew.
    # @note Updated 2021-05-25.
    # """
    local app_name file
    koopa::assert_has_args_eq "$#" 1
    app_name="${1:?}"
    file="$(koopa::which_realpath "$app_name")"
    koopa::assert_is_executable "$file"
    koopa::print "$file"
    return 0
}

koopa:::locate_gnu_app() { # {{{1
    # """
    # Locate a GNU application.
    # @note Updated 2021-05-25.
    # """
    local app_name brew_name brew_prefix file
    koopa::assert_has_args_eq "$#" 2
    brew_name="${1:?}"
    app_name="${2:?}"
    if koopa::is_macos
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        file="${brew_prefix}/opt/${brew_name}/libexec/gnubin/${app_name}"
        koopa::assert_is_executable "$file"
        koopa::print "$file"
    else
        koopa::print "$app_name"
    fi
    return 0
}

koopa::locate_7z() { # {{{1
    # """
    # Locate 7z.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'p7zip' '7z' "$@"
}

koopa::locate_awk() { # {{{1
    # """
    # Locate GNU awk.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'gawk' 'awk' "$@"
}

koopa::locate_basename() { # {{{1
    # """
    # Locate GNU basename.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'basename' "$@"
}

koopa::locate_bc() { # {{{1
    # """
    # Locate GNU bc.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'bc' 'bc' "$@"
}

koopa::locate_bunzip2() { # {{{1
    # """
    # Locate bunzip2.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'bzip2' 'bunzip2'
}

koopa::locate_chgrp() { # {{{1
    # """
    # Locate GNU chgrp.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'chgrp' "$@"
}

koopa::locate_chmod() { # {{{1
    # """
    # Locate GNU chmod.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'chmod' "$@"
}

koopa::locate_chown() { # {{{1
    # """
    # Locate GNU chown.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'chown' "$@"
}

koopa::locate_cmake() { # {{{1
    # """
    # Locate cmake.
    # @note Updated 2021-05-26.
    # """
    koopa:::locate_app 'cmake' 'cmake' "$@"
}

koopa::locate_conda() { # {{{1
    # """
    # Locate conda (or mamba).
    # @note Updated 2021-05-21.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    koopa::assert_has_no_args "$#"
    if koopa::is_installed 'mamba'
    then
        x='mamba'
    else
        x='conda'
    fi
    koopa::print "$x"
    return 0
}

koopa::locate_cp() { # {{{1
    # """
    # Locate GNU cp.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'cp' "$@"
}

koopa::locate_curl() { # {{{1
    # """
    # Locate curl.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'curl' 'curl' "$@"
}

koopa::locate_cut() { # {{{1
    # """
    # Locate GNU cut.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'cut' "$@"
}

koopa::locate_date() { # {{{1
    # """
    # Locate GNU date.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'date' "$@"
}

koopa::locate_df() { # {{{1
    # """
    # Locate GNU df.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'df' "$@"
}

koopa::locate_dirname() { # {{{1
    # """
    # Locate GNU dirname.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'dirname' "$@"
}

koopa::locate_du() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'du' "$@"
}

koopa::locate_find() { # {{{1
    # """
    # Locate GNU find.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'findutils' 'find' "$@"
}

koopa::locate_gcc() { # {{{1
    # """
    # Locate GNU gcc.
    # @note Updated 2021-05-25.
    # """
    local version
    version="$(koopa::variable 'gcc')"
    version="$(koopa::major_version "$version")"
    koopa:::locate_app "gcc@${version}" "gcc-${version}" "$@"
}

koopa::locate_git() { # {{{1
    # """
    # Locate git.
    # @note Updated 2021-05-25.
    # """
    koopa:::locate_app 'git' 'git' "$@"
}

koopa::locate_grep() { # {{{1
    # """
    # Locate GNU grep.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'grep' 'grep' "$@"
}

koopa::locate_gunzip() { # {{{1
    # """
    # Locate GNU gunzip.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'gzip' 'gunzip' "$@"
}

koopa::locate_head() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'head' "$@"
}

koopa::locate_id() { # {{{1
    # """
    # Locate GNU id.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'id' "$@"
}

koopa::locate_llvm_config() { # {{{1
    # """
    # Locate 'llvm-config' executable.
    # @note Updated 2021-05-25.
    #
    # This is versioned on many Linux systems.
    # """
    local brew_prefix find sort tail x
    x="${LLVM_CONFIG:-}"
    if [[ -z "$x" ]]
    then
        if koopa::is_linux
        then
            find="$(koopa::locate_find)"
            sort="$(koopa::locate_sort)"
            tail="$(koopa::locate_tail)"
            x="$( \
                "$find" '/usr/bin' -name 'llvm-config-*' \
                | "$sort" \
                | "$tail" -n 1 \
            )"
        elif koopa::is_macos
        then
            brew_prefix="$(koopa::homebrew_prefix)"
            x="${brew_prefix}/opt/llvm/bin/llvm-config"
        fi
    fi
    koopa::assert_is_executable "$x"
    koopa::print "$x"
    return 0
}

koopa::locate_ln() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'ln' "$@"
}

koopa::locate_ls() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'ls' "$@"
}

koopa::locate_make() { # {{{1
    # """
    # Locate GNU make.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'make' 'make' "$@"
}

koopa::locate_man() { # {{{1
    # """
    # Locate GNU man-db.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'man-db' 'man' "$@"
}

koopa::locate_mkdir() { # {{{1
    # """
    # Locate GNU mkdir.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'mkdir' "$@"
}

koopa::locate_mktemp() { # {{{1
    # """
    # Locate GNU mktemp.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'mktemp' "$@"
}

koopa::locate_mv() { # {{{1
    # """
    # Locate GNU mv.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'mv' "$@"
}

koopa::locate_openssl() { # {{{1
    # """
    # Locate openssl.
    # @note Updated 2021-05-26.
    # """
    local x
    x='/bin/openssl'
    [[ -x "$x" ]] || return 1
    koopa::print "$x"
}

koopa::locate_parallel() { # {{{1
    # """
    # Locate GNU parallel.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'parallel' 'parallel' "$@"
}

koopa::locate_paste() { # {{{1
    # """
    # Locate GNU paste.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'paste' "$@"
}

koopa::locate_patch() { # {{{1
    # """
    # Locate GNU patch.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'gpatch' 'patch' "$@"
}

koopa::locate_pcregrep() { # {{{1
    # """
    # Locate pcregrep.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'pcre' 'pcregrep' "$@"
}

koopa::locate_pkg_config() { # {{{1
    # """
    # Locate pkg-config.
    # @note Updated 2021-05-24.
    # """
    koopa:::locate_app 'pkg-config' 'pkg-config' "$@"
}

koopa::locate_python() { # {{{1
    # """
    # Locate Python.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app_simple 'python3'
}

koopa::locate_r() { # {{{1
    # """
    # Locate R.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app_simple 'R'
}

koopa::locate_readlink() { # {{{1
    # """
    # Locate GNU readlink.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'readlink' "$@"
}

koopa::locate_realpath() { # {{{1
    # """
    # Locate GNU realpath.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'realpath' "$@"
}

koopa::locate_rename() { # {{{1
    # """
    # Locate Perl rename.
    # @note Updated 2021-05-24.
    # """
    local file prefix
    prefix="$(koopa::perl_packages_prefix)"
    file="${prefix}/bin/rename"
    koopa::assert_is_executable "$file"
    koopa::print "$file"
    return 0
}

koopa::locate_rm() { # {{{1
    # """
    # Locate GNU rm.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'rm' "$@"
}

koopa::locate_rsync() { # {{{1
    # """
    # Locate rsync.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'rsync' 'rsync' "$@"
}

koopa::locate_sed() { # {{{1
    # """
    # Locate GNU sed.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'gnu-sed' 'sed' "$@"
}

koopa::locate_sort() { # {{{1
    # """
    # Locate GNU sort.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'sort' "$@"
}

koopa::locate_ssh() { # {{{1
    # """
    # Locate ssh.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'openssh' 'ssh' "$@"
}

koopa::locate_stat() { # {{{1
    # """
    # Locate GNU stat.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'stat' "$@"
}

koopa::locate_tac() { # {{{1
    # """
    # Locate GNU tac.
    # @note Updated 2021-05-24.
    # """
    koopa:::locate_gnu_app 'coreutils' 'tac' "$@"
}

koopa::locate_tail() { # {{{1
    # """
    # Locate GNU tail.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'tail' "$@"
}

koopa::locate_tar() { # {{{1
    # """
    # Locate GNU tar.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'gnu-tar' 'tar' "$@"
}

koopa::locate_tee() { # {{{1
    # """
    # Locate GNU tee.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'tee' "$@"
}

koopa::locate_tr() { # {{{1
    # """
    # Locate GNU tr.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'tr' "$@"
}

koopa::locate_uncompress() { # {{{1
    # """
    # Locate GNU uncompress.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'gzip' 'uncompress' "$@"
}

koopa::locate_uname() { # {{{1
    # """
    # Locate GNU uname.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'uname' "$@"
}

koopa::locate_uniq() { # {{{1
    # """
    # Locate GNU uniq.
    # @note Updated 2021-05-24.
    # """
    koopa:::locate_gnu_app 'coreutils' 'uniq' "$@"
}

koopa::locate_unzip() { # {{{1
    # """
    # Locate unzip.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'unzip' 'unzip'
}

koopa::locate_wc() { # {{{1
    # """
    # Locate GNU wc.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'coreutils' 'wc' "$@"
}

koopa::locate_wget() { # {{{1
    # """
    # Locate wget.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_app 'wget' 'wget' "$@"
}

koopa::locate_xargs() { # {{{1
    # """
    # Locate GNU xargs.
    # @note Updated 2021-05-21.
    # """
    koopa:::locate_gnu_app 'findutils' 'xargs' "$@"
}
