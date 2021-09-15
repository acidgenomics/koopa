#!/usr/bin/env bash

# FIXME Need to rework all these other locators.

# Prioritize /usr/local here instead.

# FIXME Need to use Homebrew flags here for argument parsing instead.
# FIXME If brew_name is unset, assume it's the name of the app.
# FIXME Allow optional path handling with '--gnubin' flag.

# FIXME This also needs to support positional unnamed argument.

koopa:::locate_app() { # {{{1
    # """
    # Locate file system path to an application.
    # @note Updated 2021-09-15.
    # """



    local app_name brew_name brew_prefix file
    # FIXME Rework this using argparse.
    koopa::assert_has_args_eq "$#" 2
    brew_name="${1:?}"
    app_name="${2:?}"

    # FIXME Allow user to pass in path here first.
    # FIXME If it's executable, skip the other ones.

    # FIXME Prioritize /usr/local here.


    # FIXME Ensure we set 'brew_name' if 'name' is only set.


    if koopa::is_installed 'brew'
    then
        brew_prefix="$(koopa::homebrew_prefix)"
        file="${brew_prefix}/opt/${brew_name}/bin/${app_name}"
        koopa::assert_is_executable "$file"
        koopa::print "$file"
    else
        koopa::print "$app_name"
    fi

    # FIXME Migrate the located app here.
    return 0
}

koopa:::locate_app_simple() { # {{{1
    # """
    # Simpler app location fetcher that doesn't attempt to use Homebrew.
    # @note Updated 2021-09-15.
    # """
    local x
    koopa::assert_has_args_eq "$#" 1
    x="${1:?}"
    x="$(koopa::which_realpath "$x")"
    [[ -z "$x" ]] && koopa::stop "Failed to locate '${x}'."
    koopa::assert_is_executable "$x"
    koopa::print "$x"
    return 0
}

# FIXME Rework this using locate_app above, with different brew subdir approach.
# FIXME Define '--gnubin' internally for this function.
# FIXME Take this out in favor of just passing '--gnubin' flag (simpler).
koopa:::locate_gnu_app() { # {{{1
    # """
    # Locate a GNU application.
    # @note Updated 2021-09-15.
    # """
    local app_name brew_name brew_prefix file
    koopa::assert_has_args_eq "$#" 2
    brew_name="${1:?}"
    app_name="${2:?}"
    if koopa::is_installed 'brew'
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
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='p7zip' \
        --name='7z'
}

koopa::locate_awk() { # {{{1
    # """
    # Locate GNU awk.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='gawk' \
        --gnubin \
        --name='awk'
}

koopa::locate_basename() { # {{{1
    # """
    # Locate GNU basename.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='basename'
}

koopa::locate_bc() { # {{{1
    # """
    # Locate GNU bc.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'bc'
}

koopa::locate_bunzip2() { # {{{1
    # """
    # Locate bunzip2.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='bzip2' \
        --name='bunzip2'
}

koopa::locate_chgrp() { # {{{1
    # """
    # Locate GNU chgrp.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='chgrp'
}

koopa::locate_chmod() { # {{{1
    # """
    # Locate GNU chmod.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='chmod'
}

koopa::locate_chown() { # {{{1
    # """
    # Locate GNU chown.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='chown'
}

koopa::locate_cmake() { # {{{1
    # """
    # Locate cmake.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'cmake'
}

koopa::locate_conda() { # {{{1
    # """
    # Locate conda.
    # @note Updated 2021-05-26.
    #
    # @seealso
    # - https://github.com/mamba-org/mamba
    # - https://github.com/conda-forge/miniforge
    # """
    local x
    koopa::assert_has_no_args "$#"
    if ! koopa::is_function conda
    then
        koopa::activate_conda
    fi
    x="$(koopa::which_realpath 'conda')"
    koopa:::locate_app "$x"
}

koopa::locate_cp() { # {{{1
    # """
    # Locate GNU cp.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='cp'
}

koopa::locate_curl() { # {{{1
    # """
    # Locate curl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'curl'
}

koopa::locate_cut() { # {{{1
    # """
    # Locate GNU cut.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='cut'
}

koopa::locate_date() { # {{{1
    # """
    # Locate GNU date.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='date'
}

koopa::locate_df() { # {{{1
    # """
    # Locate GNU df.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='df'
}

koopa::locate_dirname() { # {{{1
    # """
    # Locate GNU dirname.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='dirname'
}

koopa::locate_doom() { # {{{1
    # """
    # Locate Doom Emacs.
    # @note Updated 2021-09-15.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::doom_emacs_prefix)"
    koopa:::locate_app "${prefix}/bin/doom"
}

koopa::locate_du() { # {{{1
    # """
    # Locate GNU du.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='du'
}

koopa::locate_emacs() { # {{{1
    # """
    # Locate Emacs.
    # @note Updated 2021-09-15.
    # """
    local app
    koopa::assert_has_no_args "$#"
    app='emacs'
    # FIXME Can we pass this in as a flag instead?
    if koopa::is_macos
    then
        app='/Applications/Emacs.app/Contents/MacOS/Emacs'
    fi
    koopa:::locate_app "$app"
}

koopa::locate_find() { # {{{1
    # """
    # Locate GNU find.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='findutils' \
        --gnubin \
        --name='find'
}

koopa::locate_gcc() { # {{{1
    # """
    # Locate GNU gcc.
    # @note Updated 2021-09-15.
    # """
    local name version
    koopa::assert_has_no_args "$#"
    name='gcc'
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    koopa:::locate_app \
        --brew-name="${name}@${version}" \
        --name="${name}-${version}"
}

koopa::locate_git() { # {{{1
    # """
    # Locate git.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'git'
}

koopa::locate_gpg() { # {{{1
    # """
    # Locate gpg.
    # @note Updated 2021-09-15.
    # """
    local app
    koopa::assert_has_no_args "$#"
    app='gpg'
    # FIXME Can we pass this in as a flag instead?
    if koopa::is_macos
    then
        app="/usr/local/MacGPG2/bin/${app}"
    fi
    koopa:::locate_app "$app"
}

koopa::locate_grep() { # {{{1
    # """
    # Locate GNU grep.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --gnubin \
        --name='grep'
}

koopa::locate_gunzip() { # {{{1
    # """
    # Locate GNU gunzip.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='gzip' \
        --name='gunzip'
}

koopa::locate_gzip() { # {{{1
    # """
    # Locate GNU gzip.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'gzip'
}

koopa::locate_head() { # {{{1
    # """
    # Locate GNU head.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='head'
}

koopa::locate_id() { # {{{1
    # """
    # Locate GNU id.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='id'
}

koopa::locate_julia() { # {{{1
    # """
    # Locate Julia.
    # @note Updated 2021-09-15.
    # """
    local app prefix
    koopa::assert_has_no_args "$#"
    app='julia'
    # FIXME Can we pass this in as a flag instead?
    if koopa::is_macos
    then
        prefix="$(koopa::macos_julia_prefix)"
        app="${prefix}/bin/${app}"
    fi
    koopa:::locate_app "$app"
}

# FIXME Rework this one, it's a bit complicated.
koopa::locate_llvm_config() { # {{{1
    # """
    # Locate 'llvm-config' executable.
    # @note Updated 2021-09-15.
    #
    # This is versioned on many Linux systems.
    # """
    local brew_prefix find sort tail x
    koopa::assert_has_no_args "$#"
    x="${LLVM_CONFIG:-}"
    if [[ -z "$x" ]]
    then
        if koopa::is_installed 'brew'
        then
            brew_prefix="$(koopa::homebrew_prefix)"
            x="${brew_prefix}/opt/llvm/bin/llvm-config"
        else
            find="$(koopa::locate_find)"
            sort="$(koopa::locate_sort)"
            tail="$(koopa::locate_tail)"
            x="$( \
                "$find" '/usr/bin' -name 'llvm-config-*' \
                | "$sort" \
                | "$tail" -n 1 \
            )"
        fi
    fi
    koopa:::locate_app "$x"
}

koopa::locate_ln() { # {{{1
    # """
    # Locate GNU ln.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='ln'
}

koopa::locate_ls() { # {{{1
    # """
    # Locate GNU ls.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='ls'
}

koopa::locate_make() { # {{{1
    # """
    # Locate GNU make.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --gnubin \
        --name='make'
}

koopa::locate_man() { # {{{1
    # """
    # Locate GNU man.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='man-db' \
        --gnubin \
        --name='man'
}

koopa::locate_mkdir() { # {{{1
    # """
    # Locate GNU mkdir.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='mkdir'
}

koopa::locate_mktemp() { # {{{1
    # """
    # Locate GNU mktemp.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='mktemp'
}

koopa::locate_mv() { # {{{1
    # """
    # Locate GNU mv.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='mv'
}

koopa::locate_openssl() { # {{{1
    # """
    # Locate openssl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'openssl'
}

koopa::locate_parallel() { # {{{1
    # """
    # Locate GNU parallel.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'parallel'
}

koopa::locate_paste() { # {{{1
    # """
    # Locate GNU paste.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='paste'
}

koopa::locate_patch() { # {{{1
    # """
    # Locate GNU patch.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='gpatch' \
        --name='patch'
}

koopa::locate_pcregrep() { # {{{1
    # """
    # Locate pcregrep.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='pcre' \
        --name='pcregrep'
}

koopa::locate_perl() { # {{{1
    # """
    # Locate perl.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'perl'
}

koopa::locate_pkg_config() { # {{{1
    # """
    # Locate pkg-config.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'pkg-config'
}

koopa::locate_python() { # {{{1
    # """
    # Locate Python.
    # @note Updated 2021-09-15.
    # """
    local app name prefix version
    koopa::assert_has_no_args "$#"
    name='python'
    version="$(koopa::variable "$name")"
    version="$(koopa::major_version "$version")"
    app="${name}${version}"
    # FIXME Can we pass this in as a flag instead?
    if koopa::is_macos
    then
        prefix="$(koopa::macos_python_prefix)"
        app="${prefix}/bin/${app}"
    fi
    koopa:::locate_app "$app"
}

koopa::locate_r() { # {{{1
    # """
    # Locate R.
    # @note Updated 2021-09-15.
    # """
    local app prefix
    koopa::assert_has_no_args "$#"
    app='R'
    # FIXME Can we pass this in as a flag instead?
    if koopa::is_macos
    then
        prefix="$(koopa::macos_r_prefix)"
        app="${prefix}/bin/${app}"
    fi
    koopa:::locate_app "$app"
}

koopa::locate_readlink() { # {{{1
    # """
    # Locate GNU readlink.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='readlink'
}

koopa::locate_realpath() { # {{{1
    # """
    # Locate GNU realpath.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='realpath'
}

koopa::locate_rename() { # {{{1
    # """
    # Locate Perl rename.
    # @note Updated 2021-09-15.
    # """
    local prefix
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::perl_packages_prefix)"
    koopa:::locate_app "${prefix}/bin/rename"
}

koopa::locate_rm() { # {{{1
    # """
    # Locate GNU rm.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='rm'
}

koopa::locate_rsync() { # {{{1
    # """
    # Locate rsync.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'rsync'
}

koopa::locate_ruby() { # {{{1
    # """
    # Locate ruby.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'ruby'
}

koopa::locate_sed() { # {{{1
    # """
    # Locate GNU sed.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='gnu-sed' \
        --gnubin \
        --name='sed'
}

koopa::locate_sort() { # {{{1
    # """
    # Locate GNU sort.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='sort'
}

koopa::locate_ssh() { # {{{1
    # """
    # Locate ssh.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='openssh' \
        --name='ssh'
}

koopa::locate_stat() { # {{{1
    # """
    # Locate GNU stat.
    # @note Updated 2021-09-15.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app \
        --brew-name='coreutils' \
        --gnubin \
        --name='stat'
}

koopa::locate_svn() { # {{{1
    # """
    # Locate svn.
    # @note Updated 2021-05-27.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'svn' 'svn' "$@"
}

koopa::locate_tac() { # {{{1
    # """
    # Locate GNU tac.
    # @note Updated 2021-05-24.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'tac' "$@"
}

koopa::locate_tail() { # {{{1
    # """
    # Locate GNU tail.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'tail' "$@"
}

koopa::locate_tar() { # {{{1
    # """
    # Locate GNU tar.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'gnu-tar' 'tar' "$@"
}

koopa::locate_tee() { # {{{1
    # """
    # Locate GNU tee.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'tee' "$@"
}

koopa::locate_tr() { # {{{1
    # """
    # Locate GNU tr.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'tr' "$@"
}

koopa::locate_uncompress() { # {{{1
    # """
    # Locate GNU uncompress.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'gzip' 'uncompress' "$@"
}

koopa::locate_uname() { # {{{1
    # """
    # Locate GNU uname.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'uname' "$@"
}

koopa::locate_uniq() { # {{{1
    # """
    # Locate GNU uniq.
    # @note Updated 2021-05-24.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'uniq' "$@"
}

koopa::locate_unzip() { # {{{1
    # """
    # Locate unzip.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'unzip' 'unzip'
}

koopa::locate_wc() { # {{{1
    # """
    # Locate GNU wc.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'coreutils' 'wc' "$@"
}

koopa::locate_wget() { # {{{1
    # """
    # Locate wget.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_app 'wget' 'wget' "$@"
}

koopa::locate_xargs() { # {{{1
    # """
    # Locate GNU xargs.
    # @note Updated 2021-05-21.
    # """
    koopa::assert_has_no_args "$#"
    koopa:::locate_gnu_app 'findutils' 'xargs' "$@"
}
