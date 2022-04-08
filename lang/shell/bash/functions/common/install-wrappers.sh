#!/usr/bin/env bash

# Core ==================================================================== {{{1

# GNU --------------------------------------------------------------------- {{{2

koopa_install_gnu_app() { # {{{3
    koopa_install_app \
        --installer='gnu-app' \
        "$@"
}

# koopa ------------------------------------------------------------------- {{{2

koopa_uninstall_koopa() { # {{{3
    local app
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    "${app[bash]}" "$(koopa_koopa_prefix)/uninstall" "$@"
    return 0
}

koopa_update_koopa() { # {{{3
    koopa_update_app \
        --name='koopa' \
        --prefix="$(koopa_koopa_prefix)" \
        "$@"
}

# Shared ================================================================== {{{1

# anaconda ---------------------------------------------------------------- {{{2

koopa_install_anaconda() { # {{{3
    koopa_install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}

koopa_uninstall_anaconda() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}

# armadillo --------------------------------------------------------------- {{{2

koopa_install_armadillo() { # {{{3
    koopa_install_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}

koopa_uninstall_armadillo() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}

# autoconf ---------------------------------------------------------------- {{{2

koopa_install_autoconf() { # {{{3
    local install_args
    install_args=('--name=autoconf')
    # m4 is required for automake to build.
    if koopa_is_macos
    then
        install_args+=('--activate-homebrew-opt=m4')
    fi
    koopa_install_gnu_app "${install_args[@]}" "$@"
}

koopa_uninstall_autoconf() { # {{{3
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

# automake ---------------------------------------------------------------- {{{2

koopa_install_automake() { # {{{3
    koopa_install_gnu_app \
        --activate-opt='autoconf' \
        --name='automake' \
        "$@"
}

koopa_uninstall_automake() { # {{{3
    koopa_uninstall_app \
        --name='automake' \
        "$@"
}

# bash -------------------------------------------------------------------- {{{2

koopa_install_bash() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/bash' \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

# FIXME Need to test this.
koopa_uninstall_bash() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        --unlink-app-in-bin='bash' \
        "$@"
}

# binutils ---------------------------------------------------------------- {{{2

koopa_install_binutils() { # {{{3
    koopa_install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa_uninstall_binutils() { # {{{3
    koopa_uninstall_app \
        --name='binutils' \
        "$@"
}

# boost ------------------------------------------------------------------- {{{2

koopa_install_boost() { # {{{3
    koopa_install_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}

koopa_uninstall_boost() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}

# chemacs ----------------------------------------------------------------- {{{2

koopa_install_chemacs() { # {{{3
    koopa_install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_chemacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa_update_chemacs() { # {{{3
    koopa_update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

# cmake ------------------------------------------------------------------- {{{2

koopa_install_cmake() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/cmake' \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
}

koopa_uninstall_cmake() { # {{{3
    koopa_uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}

# conda ------------------------------------------------------------------- {{{2

koopa_install_conda() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/conda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        "$@"
}

koopa_uninstall_conda() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        --unlink-in-bin='conda' \
        "$@"
}

# coreutils --------------------------------------------------------------- {{{2

koopa_install_coreutils() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/[' \
        --link-in-bin='bin/b2sum' \
        --link-in-bin='bin/base32' \
        --link-in-bin='bin/base64' \
        --link-in-bin='bin/basename' \
        --link-in-bin='bin/basenc' \
        --link-in-bin='bin/cat' \
        --link-in-bin='bin/chcon' \
        --link-in-bin='bin/chgrp' \
        --link-in-bin='bin/chmod' \
        --link-in-bin='bin/chown' \
        --link-in-bin='bin/chroot' \
        --link-in-bin='bin/cksum' \
        --link-in-bin='bin/comm' \
        --link-in-bin='bin/cp' \
        --link-in-bin='bin/csplit' \
        --link-in-bin='bin/cut' \
        --link-in-bin='bin/date' \
        --link-in-bin='bin/dd' \
        --link-in-bin='bin/df' \
        --link-in-bin='bin/dir' \
        --link-in-bin='bin/dircolors' \
        --link-in-bin='bin/dirname' \
        --link-in-bin='bin/du' \
        --link-in-bin='bin/echo' \
        --link-in-bin='bin/env' \
        --link-in-bin='bin/expand' \
        --link-in-bin='bin/expr' \
        --link-in-bin='bin/factor' \
        --link-in-bin='bin/false' \
        --link-in-bin='bin/fmt' \
        --link-in-bin='bin/fold' \
        --link-in-bin='bin/groups' \
        --link-in-bin='bin/head' \
        --link-in-bin='bin/hostid' \
        --link-in-bin='bin/id' \
        --link-in-bin='bin/install' \
        --link-in-bin='bin/join' \
        --link-in-bin='bin/kill' \
        --link-in-bin='bin/link' \
        --link-in-bin='bin/ln' \
        --link-in-bin='bin/logname' \
        --link-in-bin='bin/ls' \
        --link-in-bin='bin/md5sum' \
        --link-in-bin='bin/mkdir' \
        --link-in-bin='bin/mkfifo' \
        --link-in-bin='bin/mknod' \
        --link-in-bin='bin/mktemp' \
        --link-in-bin='bin/mv' \
        --link-in-bin='bin/nice' \
        --link-in-bin='bin/nl' \
        --link-in-bin='bin/nohup' \
        --link-in-bin='bin/nproc' \
        --link-in-bin='bin/numfmt' \
        --link-in-bin='bin/od' \
        --link-in-bin='bin/paste' \
        --link-in-bin='bin/pathchk' \
        --link-in-bin='bin/pinky' \
        --link-in-bin='bin/pr' \
        --link-in-bin='bin/printenv' \
        --link-in-bin='bin/printf' \
        --link-in-bin='bin/ptx' \
        --link-in-bin='bin/pwd' \
        --link-in-bin='bin/readlink' \
        --link-in-bin='bin/realpath' \
        --link-in-bin='bin/rm' \
        --link-in-bin='bin/rmdir' \
        --link-in-bin='bin/runcon' \
        --link-in-bin='bin/seq' \
        --link-in-bin='bin/sha1sum' \
        --link-in-bin='bin/sha224sum' \
        --link-in-bin='bin/sha256sum' \
        --link-in-bin='bin/sha384sum' \
        --link-in-bin='bin/sha512sum' \
        --link-in-bin='bin/shred' \
        --link-in-bin='bin/shuf' \
        --link-in-bin='bin/sleep' \
        --link-in-bin='bin/sort' \
        --link-in-bin='bin/split' \
        --link-in-bin='bin/stat' \
        --link-in-bin='bin/stdbuf' \
        --link-in-bin='bin/stty' \
        --link-in-bin='bin/sum' \
        --link-in-bin='bin/sync' \
        --link-in-bin='bin/tac' \
        --link-in-bin='bin/tail' \
        --link-in-bin='bin/tee' \
        --link-in-bin='bin/test' \
        --link-in-bin='bin/timeout' \
        --link-in-bin='bin/touch' \
        --link-in-bin='bin/tr' \
        --link-in-bin='bin/true' \
        --link-in-bin='bin/truncate' \
        --link-in-bin='bin/tsort' \
        --link-in-bin='bin/tty' \
        --link-in-bin='bin/uname' \
        --link-in-bin='bin/unexpand' \
        --link-in-bin='bin/uniq' \
        --link-in-bin='bin/unlink' \
        --link-in-bin='bin/uptime' \
        --link-in-bin='bin/users' \
        --link-in-bin='bin/vdir' \
        --link-in-bin='bin/wc' \
        --link-in-bin='bin/who' \
        --link-in-bin='bin/whoami' \
        --link-in-bin='bin/yes' \
        --name='coreutils' \
        "$@"
}

koopa_uninstall_coreutils() { # {{{3
    koopa_uninstall_app \
        --name='coreutils' \
        --unlink-in-bin='[' \
        --unlink-in-bin='b2sum' \
        --unlink-in-bin='base32' \
        --unlink-in-bin='base64' \
        --unlink-in-bin='basename' \
        --unlink-in-bin='basenc' \
        --unlink-in-bin='cat' \
        --unlink-in-bin='chcon' \
        --unlink-in-bin='chgrp' \
        --unlink-in-bin='chmod' \
        --unlink-in-bin='chown' \
        --unlink-in-bin='chroot' \
        --unlink-in-bin='cksum' \
        --unlink-in-bin='comm' \
        --unlink-in-bin='cp' \
        --unlink-in-bin='csplit' \
        --unlink-in-bin='cut' \
        --unlink-in-bin='date' \
        --unlink-in-bin='dd' \
        --unlink-in-bin='df' \
        --unlink-in-bin='dir' \
        --unlink-in-bin='dircolors' \
        --unlink-in-bin='dirname' \
        --unlink-in-bin='du' \
        --unlink-in-bin='echo' \
        --unlink-in-bin='env' \
        --unlink-in-bin='expand' \
        --unlink-in-bin='expr' \
        --unlink-in-bin='factor' \
        --unlink-in-bin='false' \
        --unlink-in-bin='fmt' \
        --unlink-in-bin='fold' \
        --unlink-in-bin='groups' \
        --unlink-in-bin='head' \
        --unlink-in-bin='hostid' \
        --unlink-in-bin='id' \
        --unlink-in-bin='install' \
        --unlink-in-bin='join' \
        --unlink-in-bin='kill' \
        --unlink-in-bin='link' \
        --unlink-in-bin='ln' \
        --unlink-in-bin='logname' \
        --unlink-in-bin='ls' \
        --unlink-in-bin='md5sum' \
        --unlink-in-bin='mkdir' \
        --unlink-in-bin='mkfifo' \
        --unlink-in-bin='mknod' \
        --unlink-in-bin='mktemp' \
        --unlink-in-bin='mv' \
        --unlink-in-bin='nice' \
        --unlink-in-bin='nl' \
        --unlink-in-bin='nohup' \
        --unlink-in-bin='nproc' \
        --unlink-in-bin='numfmt' \
        --unlink-in-bin='od' \
        --unlink-in-bin='paste' \
        --unlink-in-bin='pathchk' \
        --unlink-in-bin='pinky' \
        --unlink-in-bin='pr' \
        --unlink-in-bin='printenv' \
        --unlink-in-bin='printf' \
        --unlink-in-bin='ptx' \
        --unlink-in-bin='pwd' \
        --unlink-in-bin='readlink' \
        --unlink-in-bin='realpath' \
        --unlink-in-bin='rm' \
        --unlink-in-bin='rmdir' \
        --unlink-in-bin='runcon' \
        --unlink-in-bin='seq' \
        --unlink-in-bin='sha1sum' \
        --unlink-in-bin='sha224sum' \
        --unlink-in-bin='sha256sum' \
        --unlink-in-bin='sha384sum' \
        --unlink-in-bin='sha512sum' \
        --unlink-in-bin='shred' \
        --unlink-in-bin='shuf' \
        --unlink-in-bin='sleep' \
        --unlink-in-bin='sort' \
        --unlink-in-bin='split' \
        --unlink-in-bin='stat' \
        --unlink-in-bin='stdbuf' \
        --unlink-in-bin='stty' \
        --unlink-in-bin='sum' \
        --unlink-in-bin='sync' \
        --unlink-in-bin='tac' \
        --unlink-in-bin='tail' \
        --unlink-in-bin='tee' \
        --unlink-in-bin='test' \
        --unlink-in-bin='timeout' \
        --unlink-in-bin='touch' \
        --unlink-in-bin='tr' \
        --unlink-in-bin='true' \
        --unlink-in-bin='truncate' \
        --unlink-in-bin='tsort' \
        --unlink-in-bin='tty' \
        --unlink-in-bin='uname' \
        --unlink-in-bin='unexpand' \
        --unlink-in-bin='uniq' \
        --unlink-in-bin='unlink' \
        --unlink-in-bin='uptime' \
        --unlink-in-bin='users' \
        --unlink-in-bin='vdir' \
        --unlink-in-bin='wc' \
        --unlink-in-bin='who' \
        --unlink-in-bin='whoami' \
        --unlink-in-bin='yes' \
        "$@"
}

# cpufetch ---------------------------------------------------------------- {{{2

koopa_install_cpufetch() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/cpufetch' \
        --name='cpufetch' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_cpufetch() { # {{{3
    koopa_uninstall_app \
        --name='cpufetch' \
        "$@"
}

# curl -------------------------------------------------------------------- {{{2

koopa_install_curl() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/curl' \
        --link-in-bin='bin/curl-config' \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_uninstall_curl() { # {{{3
    koopa_uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        --unlink-in-bin='curl' \
        --unlink-in-bin='curl-config' \
        "$@"
}

# dotfiles ---------------------------------------------------------------- {{{2

koopa_install_dotfiles() { # {{{3
    koopa_install_app \
        --name-fancy='Dotfiles' \
        --name='dotfiles' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_dotfiles() { # {{{3
    # """
    # Uninstall dotfiles.
    # @note Updated 2022-02-15.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    declare -A dict=(
        [name_fancy]='Dotfiles'
        [name]='dotfiles'
        [prefix]="$(koopa_dotfiles_prefix)"
    )
    dict[script]="${dict[prefix]}/uninstall"
    koopa_assert_is_file "${dict[script]}"
    "${app[bash]}" "${dict[script]}"
    koopa_uninstall_app \
        --name-fancy="${dict[name_fancy]}" \
        --name="${dict[name]}" \
        --prefix="${dict[prefix]}" \
        "$@"
    return 0
}

koopa_update_dotfiles() { # {{{3
    koopa_update_app \
        --name='dotfiles' \
        --name-fancy='Dotfiles' \
        "$@"
}

# emacs ------------------------------------------------------------------- {{{2

koopa_install_emacs() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/emacs' \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_emacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

# ensembl-perl-api -------------------------------------------------------- {{{2

koopa_install_ensembl_perl_api() { # {{{3
    koopa_install_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_ensembl_perl_api() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        "$@"
}

# findutils --------------------------------------------------------------- {{{2

koopa_install_findutils() { # {{{3
    if koopa_is_macos
    then
        # Workaround for build failures in 4.8.0.
        # See also:
        # - https://github.com/Homebrew/homebrew-core/blob/master/
        #     Formula/findutils.rb
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00050.html
        # - https://lists.gnu.org/archive/html/bug-findutils/2021-01/
        #     msg00051.html
        export CFLAGS='-D__nonnull\(params\)='
    fi
    koopa_install_gnu_app \
        --link-in-bin='bin/find' \
        --link-in-bin='bin/locate' \
        --link-in-bin='bin/updatedb' \
        --link-in-bin='bin/xargs' \
        --name='findutils' \
        "$@"
}

koopa_uninstall_findutils() { # {{{3
    koopa_uninstall_app \
        --name='findutils' \
        --unlink-in-bin='find' \
        --unlink-in-bin='locate' \
        --unlink-in-bin='updatedb' \
        --unlink-in-bin='xargs' \
        "$@"
}

# fish -------------------------------------------------------------------- {{{2

koopa_install_fish() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/fish' \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_fish() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

# fzf --------------------------------------------------------------------- {{{2

koopa_install_fzf() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/fzf' \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_fzf() { # {{{3
    koopa_uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

# gawk -------------------------------------------------------------------- {{{2

# FIXME Need to add links here.
koopa_install_gawk() { # {{{3
    koopa_install_gnu_app \
        --name='gawk' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_gawk() { # {{{3
    koopa_uninstall_app \
        --name='gawk' \
        "$@"
}

# gcc --------------------------------------------------------------------- {{{2

koopa_install_gcc() { # {{{3
    koopa_install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}

koopa_uninstall_gcc() { # {{{3
    koopa_uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}

# gdal -------------------------------------------------------------------- {{{2

koopa_install_gdal() { # {{{3
    koopa_install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}

koopa_uninstall_gdal() { # {{{3
    koopa_uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}

# geos -------------------------------------------------------------------- {{{2

koopa_install_geos() { # {{{3
    koopa_install_app \
        --name-fancy='GEOS' \
        --name='geos' \
        "$@"
}

koopa_uninstall_geos() { # {{{3
    koopa_uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        "$@"
}

# git --------------------------------------------------------------------- {{{2

koopa_install_git() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/git' \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_git() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

# gnupg ------------------------------------------------------------------- {{{2

# FIXME Need to add links here.
koopa_install_gnupg() { # {{{3
    koopa_install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa_uninstall_gnupg() { # {{{3
    koopa_uninstall_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

# go ---------------------------------------------------------------------- {{{2

koopa_install_go() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/go' \
        --name-fancy='Go' \
        --name='go' \
        "$@"
    return 0
}

# FIXME Need to unlink in bin here.
koopa_uninstall_go() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        "$@"
}

# go-packages ------------------------------------------------------------- {{{2

koopa_uninstall_go_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Go packages' \
        --name='go-packages' \
        "$@"
}

# grep -------------------------------------------------------------------- {{{2

koopa_install_grep() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/egrep' \
        --link-in-bin='bin/fgrep' \
        --link-in-bin='bin/grep' \
        --name='grep' \
        "$@"
}

koopa_uninstall_grep() { # {{{3
    koopa_uninstall_app \
        --name='grep' \
        --unlink-in-bin='egrep' \
        --unlink-in-bin='fgrep' \
        --unlink-in-bin='grep' \
        "$@"
}

# groff ------------------------------------------------------------------- {{{2

koopa_install_groff() { # {{{3
    koopa_install_gnu_app \
        --name='groff' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_groff() { # {{{3
    koopa_uninstall_app \
        --name='groff' \
        "$@"
}

# gsl --------------------------------------------------------------------- {{{2

koopa_install_gsl() { # {{{3
    koopa_install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

koopa_uninstall_gsl() { # {{{3
    koopa_uninstall_app \
        --name='gsl' \
        "$@"
}

# hadolint ---------------------------------------------------------------- {{{2

koopa_install_hadolint() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/hadolint' \
        --name='hadolint' \
        "$@"
}

koopa_uninstall_hadolint() { # {{{3
    koopa_uninstall_app \
        --name='hadolint' \
        --unlink-in-bin='hadolint' \
        "$@"
}

# harfbuzz ---------------------------------------------------------------- {{{2

koopa_install_harfbuzz() { # {{{3
    koopa_install_app \
        --name-fancy='HarfBuzz' \
        --name='harfbuzz' \
        "$@"
}

koopa_uninstall_harfbuzz() { # {{{3
    koopa_uninstall_app \
        --name-fancy='HarfBuzz' \
        --name='harfbuzz' \
        "$@"
}

# haskell-stack ----------------------------------------------------------- {{{2

koopa_install_haskell_stack() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/stack' \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_haskell_stack() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --unlink-in-bin='stack' \
        "$@"
}

# hdf5 -------------------------------------------------------------------- {{{2

koopa_install_hdf5() { # {{{3
    koopa_install_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa_uninstall_hdf5() { # {{{3
    koopa_uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

# htop -------------------------------------------------------------------- {{{2

koopa_install_htop() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/htop' \
        --name='htop' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_htop() { # {{{3
    koopa_uninstall_app \
        --name='htop' \
        "$@"
}

# icu4c ------------------------------------------------------------------- {{{2

koopa_install_icu4c() { # {{{3
    koopa_install_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

koopa_uninstall_icu4c() { # {{{3
    koopa_uninstall_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

# imagemagick ------------------------------------------------------------- {{{2

koopa_install_imagemagick() { # {{{3
    koopa_install_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_uninstall_imagemagick() { # {{{3
    koopa_uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

# juila ------------------------------------------------------------------- {{{2

koopa_install_julia() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_uninstall_julia() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Julia' \
        --name='julia' \
        --unlink-in-bin='julia' \
        "$@"
}

# julia-packages ---------------------------------------------------------- {{{2

# FIXME Specify which packages to link.
koopa_install_julia_packages() { # {{{3
    koopa_install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

# FIXME Specify which packages to unlink.
koopa_uninstall_julia_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        "$@"
}

koopa_update_julia_packages() { # {{{3
    koopa_install_julia_packages "$@"
}

# lesspipe ---------------------------------------------------------------- {{{2

koopa_install_lesspipe() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/lesspipe.sh' \
        --name='lesspipe' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_lesspipe() { # {{{3
    koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

# libevent ---------------------------------------------------------------- {{{2

koopa_install_libevent() { # {{{3
    koopa_install_app \
        --name='libevent' \
        "$@"
}

koopa_uninstall_libevent() { # {{{3
    koopa_uninstall_app \
        --name='libevent' \
        "$@"
}

# libtool ----------------------------------------------------------------- {{{2

koopa_install_libtool() { # {{{3
    koopa_install_gnu_app \
        --name='libtool' \
        "$@"
}

koopa_uninstall_libtool() { # {{{3
    koopa_uninstall_app \
        --name='libtool' \
        "$@"
}

# lua --------------------------------------------------------------------- {{{2

# FIXME Need to add link here?
koopa_install_lua() { # {{{3
    koopa_install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_lua() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

# luarocks ---------------------------------------------------------------- {{{2

# FIXME Need to add link here?
koopa_install_luarocks() { # {{{3
    koopa_install_app \
        --name='luarocks' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_luarocks() { # {{{3
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

# make -------------------------------------------------------------------- {{{2

koopa_install_make() { # {{{3
    koopa_install_gnu_app \
        --name='make' \
        "$@"
}

koopa_uninstall_make() { # {{{3
    koopa_uninstall_app \
        --name='make' \
        "$@"
}

# mamba ------------------------------------------------------------------- {{{2

koopa_install_mamba() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/mamba' \
        --name-fancy='Mamba' \
        --name='mamba' \
        --no-prefix-check \
        "$@"
}

koopa_update_mamba() { # {{{3
    koopa_install_mamba "$@"
}

# man-db ------------------------------------------------------------------ {{{2

koopa_install_man_db() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/man' \
        --name='man-db' \
        "$@"
}

koopa_uninstall_man_db() { # {{{3
    koopa_uninstall_app \
        --name='man-db' \
        --unlink-in-bin='man' \
        "$@"
}

# meson ------------------------------------------------------------------- {{{2

koopa_install_meson() { # {{{3
    koopa_install_app \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}

koopa_uninstall_meson() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}

# ncurses ----------------------------------------------------------------- {{{2

koopa_install_ncurses() { # {{{3
    koopa_install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa_uninstall_ncurses() { # {{{3
    koopa_uninstall_app \
        --name='ncurses' \
        "$@"
}

# neofetch ---------------------------------------------------------------- {{{2

koopa_install_neofetch() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/neofetch' \
        --name='neofetch' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_neofetch() { # {{{3
    koopa_uninstall_app \
        --name='neofetch' \
        "$@"
}

# neovim ------------------------------------------------------------------ {{{2

koopa_install_neovim() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/nvim' \
        --name='neovim' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_neovim() { # {{{3
    koopa_uninstall_app \
        --name='neovim' \
        "$@"
}

# nim --------------------------------------------------------------------- {{{2

koopa_install_nim() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/nim' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_nim() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

# nim-packages ------------------------------------------------------------ {{{2

koopa_install_nim_packages() { # {{{3
    koopa_install_app_packages \
        --link-in-bin='bin/markdown' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_nim_packages() { # {{{3
    koopa_uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        "$@"
}

koopa_update_nim_packages() { # {{{3
    koopa_install_nim_packages "$@"
}

# ninja ------------------------------------------------------------------- {{{2

koopa_install_ninja() { # {{{3
    koopa_install_app \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_ninja() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}

# node -------------------------------------------------------------------- {{{2

koopa_install_node() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/node' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_node() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

# node-packages ----------------------------------------------------------- {{{2

koopa_install_node_packages() { # {{{3
    koopa_install_app_packages \
        --link-in-bin='bin/bash-language-server' \
        --link-in-bin='bin/gtop' \
        --link-in-bin='bin/npm' \
        --link-in-bin='bin/prettier' \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_node_packages() { # {{{3
    koopa_uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        "$@"
}

koopa_update_node_packages() { # {{{3
    koopa_install_node_packages "$@"
}

# openjdk ----------------------------------------------------------------- {{{2

# FIXME Need to add link here?
koopa_install_openjdk() { # {{{3
    koopa_install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        "$@"
}

# FIXME Need to pass this out to an uninstall script...
# FIXME Need to make a Linux-specific wrapper.
# FIXME Need to unlink in bin here.

koopa_uninstall_openjdk() { # {{{3
    local dict
    declare -A dict
    koopa_uninstall_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        "$@"
    if koopa_is_linux
    then
        dict[default_java]='/usr/lib/jvm/default-java'
        if [[ -d "${dict[default_java]}" ]]
        then
            koopa_linux_java_update_alternatives "${dict[default_java]}"
        fi
    fi
    return 0
}

# openssh ----------------------------------------------------------------- {{{2

koopa_install_openssh() { # {{{3
    koopa_install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}

koopa_uninstall_openssh() { # {{{3
    koopa_uninstall_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}

# openssl ----------------------------------------------------------------- {{{2

koopa_install_openssl() { # {{{3
    koopa_install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}

koopa_uninstall_openssl() { # {{{3
    koopa_uninstall_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}

# parallel ---------------------------------------------------------------- {{{2

koopa_install_parallel() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/parallel' \
        --name='parallel' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_parallel() { # {{{3
    koopa_uninstall_app \
        --name='parallel' \
        "$@"
}

# password-store ---------------------------------------------------------- {{{2

koopa_install_password_store() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/pass' \
        --name='password-store' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_password_store() { # {{{3
    koopa_uninstall_app \
        --name='password-store' \
        "$@"
}

# patch ------------------------------------------------------------------- {{{2

koopa_install_patch() { # {{{3
    koopa_install_gnu_app \
        --name='patch' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_patch() { # {{{3
    koopa_uninstall_app \
        --name='patch' \
        "$@"
}

# pcre2 ------------------------------------------------------------------- {{{2

koopa_install_pcre2() { # {{{3
    koopa_install_app \
        --name-fancy='PCRE2' \
        --name='pcre2' \
        "$@"
}

koopa_uninstall_pcre2() { # {{{3
    koopa_uninstall_app \
        --name-fancy='PCRE2' \
        --name='pcre2' \
        "$@"
}

# perl -------------------------------------------------------------------- {{{2

koopa_install_perl() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/perl' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_uninstall_perl() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        --unlink-in-bin='perl' \
        "$@"
}

# perl-packages ----------------------------------------------------------- {{{2

koopa_install_perl_packages() { # {{{3
    koopa_install_app_packages \
        --link-in-bin='bin/ack' \
        --link-in-bin='bin/cpanm' \
        --link-in-bin='bin/rename' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

# FIXME Need to unlink in bin here.
# FIXME Need to include an uninstall script.
koopa_uninstall_perl_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
    koopa_rm "${HOME:?}/.cpan" "${HOME:?}/.cpanm"
    return 0
}

koopa_update_perl_packages() { # {{{3
    koopa_install_perl_packages "$@"
}

# perlbrew ---------------------------------------------------------------- {{{2

koopa_install_perlbrew() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/perlbrew' \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_perlbrew() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --unlink-in-bin='perlbrew' \
        "$@"
}

koopa_update_perlbrew() { # {{{3
    koopa_update_app \
        --name='perlbrew' \
        --name-fancy='Perlbrew' \
        "$@"
}

# pkg-config -------------------------------------------------------------- {{{2

koopa_install_pkg_config() { # {{{3
    koopa_install_app \
        --name='pkg-config' \
        "$@"
}

koopa_uninstall_pkg_config() { # {{{3
    koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}

# proj -------------------------------------------------------------------- {{{2

koopa_install_proj() { # {{{3
    koopa_install_app \
        --name-fancy='PROJ' \
        --name='proj' \
        "$@"
}

koopa_uninstall_proj() { # {{{3
    koopa_uninstall_app \
        --name-fancy='PROJ' \
        --name='proj' \
        "$@"
}

# pyenv ------------------------------------------------------------------- {{{2

koopa_install_pyenv() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/pyenv' \
        --name='pyenv' \
        --version='rolling' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_pyenv() { # {{{3
    koopa_uninstall_app \
        --name='pyenv' \
        --unlink-in-bin='pyenv' \
        "$@"
}

koopa_update_pyenv() { # {{{3
    koopa_update_app \
        --name='pyenv' \
        "$@"
}

# python ------------------------------------------------------------------ {{{2

koopa_install_python() { # {{{3
    local install_args
    install_args=(
        '--name-fancy=Python'
        '--name=python'
    )
    # Assume we're using 'python-binary' by default on macOS.
    if ! koopa_is_macos
    then
        install_args+=('--link-in-bin=bin/python3')
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_uninstall_python() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Python'
        '--name=python'
    )
    # Assume we're using 'python-binary' by default on macOS.
    if ! koopa_is_macos
    then
        uninstall_args+=('--unlink-in-bin=python3')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# python-packages --------------------------------------------------------- {{{2

# FIXME Need to include links here.
koopa_install_python_packages() { # {{{3
    koopa_install_app_packages \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_python_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        "$@"
}

# python-virtualenvs ------------------------------------------------------ {{{2

koopa_uninstall_python_virtualenvs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Python virtualenvs' \
        --name='python-virtualenvs' \
        "$@"
}

# r ----------------------------------------------------------------------- {{{2

koopa_install_r() { # {{{3
    local install_args
    install_args=(
        '--name-fancy=R'
        '--name=r'
    )
    # Assume we're using 'r-binary' by default on macOS.
    if ! koopa_is_macos
    then
        install_args+=(
            '--link-in-bin=bin/R'
            '--link-in-bin=bin/Rscript'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_uninstall_r() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name-fancy=R'
        '--name=r'
    )
    # Assume we're using 'r-binary' by default on macOS.
    if ! koopa_is_macos
    then
        uninstall_args+=(
            '--unlink-in-bin=R'
            '--unlink-in-bin=Rscript'
        )
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# r-cmd-check ------------------------------------------------------------- {{{2

koopa_install_r_cmd_check() { # {{{3
    koopa_install_app \
        --name-fancy='R CMD check' \
        --name='r-cmd-check' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_r_cmd_check() { # {{{3
    koopa_uninstall_app \
        --name='r-cmd-check' \
        "$@"
}

koopa_update_r_cmd_check() { # {{{3
    koopa_update_app \
        --name='r-cmd-check' \
        --name-fancy='R CMD check' \
        "$@"
}

# r-koopa ----------------------------------------------------------------- {{{2

koopa_install_r_koopa() { # {{{3
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'header'
    return 0
}

# r-packages -------------------------------------------------------------- {{{2

koopa_install_r_packages() { # {{{3
    koopa_install_app_packages \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_uninstall_r_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

koopa_update_r_packages() { # {{{3
    koopa_update_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

# rbenv ------------------------------------------------------------------- {{{2

koopa_install_rbenv() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/rbenv' \
        --name='rbenv' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_rbenv() { # {{{3
    koopa_uninstall_app \
        --name='rbenv' \
        --unlink-in-bin='rbenv' \
        "$@"
}

koopa_update_rbenv() { # {{{3
    koopa_update_app \
        --name='rbenv' \
        "$@"
}

# rmate ------------------------------------------------------------------- {{{2

koopa_install_rmate() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/rmate' \
        --name='rmate' \
        "$@"
}

koopa_uninstall_rmate() { # {{{3
    koopa_uninstall_app \
        --name='rmate' \
        --unlink-in-bin='rmate' \
        "$@"
}

# rsync ------------------------------------------------------------------- {{{2

koopa_install_rsync() { # {{{3
    koopa_install_app \
        --link-in-bin='rsync' \
        --name='rsync' \
        "$@"
}

koopa_uninstall_rsync() { # {{{3
    koopa_uninstall_app \
        --name='rsync' \
        --unlink-in-bin='rsync' \
        "$@"
}

# ruby -------------------------------------------------------------------- {{{2

koopa_install_ruby() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/gem' \
        --link-in-bin='bin/ruby' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_ruby() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

# ruby-packages ----------------------------------------------------------- {{{2

koopa_install_ruby_packages() { # {{{3
    koopa_install_app_packages \
        --link-in-bin='bin/bashcov' \
        --link-in-bin='bin/bundle' \
        --link-in-bin='bin/bundler' \
        --link-in-bin='bin/ronn' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_ruby_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        "$@"
}

koopa_update_ruby_packages() {  # {{{3
    koopa_install_ruby_packages "$@"
}

# rust -------------------------------------------------------------------- {{{2

koopa_install_rust() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/rustc' \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_rust() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        --unlink-in-bin='rustc' \
        "$@"
}

koopa_update_rust() { # {{{3
    koopa_update_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

# rust-packages ----------------------------------------------------------- {{{2

# FIXME Need to include links here.
koopa_install_rust_packages() { # {{{3
    koopa_install_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_rust_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa_update_rust_packages() { # {{{3
    koopa_update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

# sed --------------------------------------------------------------------- {{{2

koopa_install_sed() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/sed' \
        --name='sed' \
        "$@"
}

koopa_uninstall_sed() { # {{{3
    koopa_uninstall_app \
        --name='sed' \
        --unlink-in-bin='sed' \
        "$@"
}

# [shellcheck] ------------------------------------------------------------ {{{2

koopa_install_shellcheck() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/shellcheck' \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa_uninstall_shellcheck() { # {{{3
    koopa_uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        --unlink-in-bin='shellcheck' \
        "$@"
}

# shunit2 ----------------------------------------------------------------- {{{2

# FIXME Need to include link here?
koopa_install_shunit2() { # {{{3
    koopa_install_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_shunit2() { # {{{3
    koopa_uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

# singularity ------------------------------------------------------------- {{{2

# FIXME Need to include link here?
koopa_install_singularity() { # {{{3
    koopa_install_app \
        --name='singularity' \
        "$@"
}

# FIXME Need to unlink in bin here.
koopa_uninstall_singularity() { # {{{3
    koopa_uninstall_app \
        --name='singularity' \
        "$@"
}

# sqlite ------------------------------------------------------------------ {{{2

koopa_install_sqlite() { # {{{3
    koopa_install_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa_uninstall_sqlite() { # {{{3
    koopa_uninstall_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

# stow -------------------------------------------------------------------- {{{2

koopa_install_stow() { # {{{3
    # """
    # Install script uses 'Test::Output' Perl package.
    # """
    koopa_install_gnu_app \
        --activate-opt='perl' \
        --link-in-bin='bin/stow' \
        --name='stow' \
        "$@"
}

koopa_uninstall_stow() { # {{{3
    koopa_uninstall_app \
        --name='stow' \
        --unlink-in-bin='stow' \
        "$@"
}

# subversion -------------------------------------------------------------- {{{2

koopa_install_subversion() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/svn' \
        --name='subversion' \
        "$@"
}

koopa_uninstall_subversion() { # {{{3
    koopa_uninstall_app \
        --name='subversion' \
        --unlink-in-bin='svn' \
        "$@"
}

# taglib ------------------------------------------------------------------ {{{2

# FIXME Rework this as a Python virtualenv.
koopa_install_taglib() { # {{{3
    koopa_install_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

# FIXME We need to unlink in bin.
koopa_uninstall_taglib() { # {{{3
    koopa_uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

# tar --------------------------------------------------------------------- {{{2

koopa_install_tar() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/tar' \
        --name='tar' \
        "$@"
}

koopa_uninstall_tar() { # {{{3
    koopa_uninstall_app \
        --name='tar' \
        --unlink-in-bin='tar' \
        "$@"
}

# texinfo ----------------------------------------------------------------- {{{2

koopa_install_texinfo() { # {{{3
    koopa_install_gnu_app \
        --name='texinfo' \
        "$@"
}

koopa_uninstall_texinfo() { # {{{3
    koopa_uninstall_app \
        --name='texinfo' \
        "$@"
}

# the-silver-searcher ----------------------------------------------------- {{{2

koopa_install_the_silver_searcher() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/ag' \
        --name='the-silver-searcher' \
        "$@"
}

koopa_uninstall_the_silver_searcher() { # {{{3
    koopa_uninstall_app \
        --name='the-silver-searcher' \
        --unlink-in-bin='ag' \
        "$@"
}

# tmux -------------------------------------------------------------------- {{{2

koopa_install_tmux() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/tmux' \
        --name='tmux' \
        "$@"
}

koopa_uninstall_tmux() { # {{{3
    koopa_uninstall_app \
        --name='tmux' \
        --unlink-in-bin='tmux' \
        "$@"
}

# udunits ----------------------------------------------------------------- {{{2

koopa_install_udunits() { # {{{3
    koopa_install_app \
        --name='udunits' \
        "$@"
}

koopa_uninstall_udunits() { # {{{3
    koopa_uninstall_app \
        --name='udunits' \
        "$@"
}

# vim --------------------------------------------------------------------- {{{2

koopa_install_vim() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/vim' \
        --link-in-bin='bin/vimdiff' \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa_uninstall_vim() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Vim' \
        --name='vim' \
        --unlink-in-bin='vim' \
        --unlink-in-bin='vimdiff' \
        "$@"
}

# wget -------------------------------------------------------------------- {{{2

koopa_install_wget() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/wget' \
        --name='wget' \
        "$@"
}

koopa_uninstall_wget() { # {{{3
    koopa_uninstall_app \
        --name='wget' \
        --unlink-in-bin='wget' \
        "$@"
}

# zsh --------------------------------------------------------------------- {{{2

koopa_install_zsh() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/zsh' \
        --name-fancy='Zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}

koopa_uninstall_zsh() { # {{{3
    koopa_uninstall_app \
        --name-fancy="Zsh" \
        --name='zsh' \
        --unlink-in-bin='zsh' \
        "$@"
}

# System ================================================================== {{{1

# google-cloud-sdk -------------------------------------------------------- {{{2

koopa_update_google_cloud_sdk() { # {{{3
    koopa_update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --system \
        "$@"
}

# homebrew ---------------------------------------------------------------- {{{2

koopa_install_homebrew() { # {{{3
    koopa_install_app \
        --link-in-bin='Homebrew/bin/brew' \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_uninstall_homebrew() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        --unlink-in-bin='brew' \
        "$@"
}

koopa_update_homebrew() { # {{{3
    koopa_update_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

# homebrew-bundle --------------------------------------------------------- {{{2

koopa_install_homebrew_bundle() { # {{{3
    koopa_install_app \
        --name-fancy='Homebrew bundle' \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

# system ------------------------------------------------------------------ {{{2

koopa_update_system() { # {{{3
    koopa_update_app \
        --name='system' \
        --system \
        "$@"
}

# tex-packages ------------------------------------------------------------ {{{2

koopa_install_tex_packages() { # {{{3
    koopa_install_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        --version='rolling' \
        "$@"
}

koopa_update_tex_packages() { # {{{3
    koopa_update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}

# User ==================================================================== {{{1

# doom-emacs -------------------------------------------------------------- {{{2

koopa_install_doom_emacs() { # {{{3
    koopa_install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        --version='rolling' \
        "$@"
}

koopa_uninstall_doom_emacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

koopa_update_doom_emacs() { # {{{3
    koopa_update_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --user \
        "$@"
}

# prelude-emacs ----------------------------------------------------------- {{{2

koopa_install_prelude_emacs() { # {{{3
    koopa_install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        --version='rolling' \
        "$@"
}

koopa_uninstall_prelude_emacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

koopa_update_prelude_emacs() { # {{{3
    koopa_update_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --user \
        "$@"
}

# spacemacs --------------------------------------------------------------- {{{2

koopa_install_spacemacs() { # {{{3
    koopa_install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        --version='rolling' \
        "$@"
}

koopa_uninstall_spacemacs() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

koopa_update_spacemacs() { # {{{3
    koopa_update_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --user \
        "$@"
}

# spacevim ---------------------------------------------------------------- {{{2

koopa_install_spacevim() { # {{{3
    koopa_install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        --version='rolling' \
        "$@"
}

koopa_uninstall_spacevim() { # {{{3
    koopa_uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}

koopa_update_spacevim() { # {{{3
    koopa_update_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --user \
        "$@"
}
