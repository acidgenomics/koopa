#!/usr/bin/env bash

# Core ==================================================================== {{{1

# GNU --------------------------------------------------------------------- {{{2

koopa_install_gnu_app() { # {{{3
    koopa_install_app \
        --installer='gnu-app' \
        "$@"
}

# koopa ------------------------------------------------------------------- {{{2

koopa_install_koopa() { # {{{3
    # FIXME Should we define main 'koopa_install_koopa' installer?
    # FIXME See 'install' file for thoughts on this.
    koopa_stop 'FIXME Need to add support for this'.
}

koopa_uninstall_koopa() { # {{{3
    koopa_uninstall_app \
        --name='koopa' \
        --prefix="$(koopa_koopa_prefix)" \
        "$@"
}

koopa_update_koopa() { # {{{3
    # """
    # We are using '--no-set-permissions' here, because these are managed in
    # the updater script, to avoid ZSH compaudit warnings.
    # """
    koopa_update_app \
        --name='koopa' \
        --no-set-permissions \
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

# apr --------------------------------------------------------------------- {{{2

koopa_install_apr() { # {{{3
    koopa_install_app \
        --activate-opt='sqlite' \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}

koopa_uninstall_apr() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) library' \
        --name='apr' \
        "$@"
}

# apr-util ---------------------------------------------------------------- {{{2

koopa_install_apr_util() { # {{{3
    koopa_install_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
        "$@"
}

koopa_uninstall_apr_util() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Apache Portable Runtime (APR) utilities' \
        --name='apr-util' \
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

# attr ---------------------------------------------------------------- {{{2

koopa_install_attr() { # {{{3
    koopa_install_app \
        --name='attr' \
        "$@"
}

koopa_uninstall_attr() { # {{{3
    koopa_uninstall_app \
        --name='attr' \
        "$@"
}

# autoconf ---------------------------------------------------------------- {{{2

koopa_install_autoconf() { # {{{3
    koopa_install_gnu_app \
        --name='autoconf' \
        "$@"
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

# aws-cli ----------------------------------------------------------------- {{{2

koopa_uninstall_aws_cli() { # {{{3
    koopa_uninstall_app \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --unlink-in-bin='aws' \
        "$@"
}

# bash -------------------------------------------------------------------- {{{2

# NOTE This can cause shell to error when reinstalling current linked version.
koopa_install_bash() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/bash' \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

# NOTE This can cause shell to error when uninstalling current linked version.
koopa_uninstall_bash() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        --unlink-app-in-bin='bash' \
        "$@"
}

# bat --------------------------------------------------------------------- {{{2

koopa_install_bat() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/bat' \
        --name='bat' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_bat() { # {{{3
    koopa_uninstall_app \
        --name='bat' \
        --unlink-in-bin='bat' \
        "$@"
}

# bc ---------------------------------------------------------------------- {{{2

koopa_install_bc() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/bc' \
        --name='bc' \
        "$@"
}

koopa_uninstall_autoconf() { # {{{3
    koopa_uninstall_app \
        --name='bc' \
        --unlink-in-bin='bc' \
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

# black ------------------------------------------------------------------- {{{2

koopa_install_black() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/black' \
        --name='black' \
        "$@"
}

koopa_uninstall_black() { # {{{3
    koopa_uninstall_app \
        --name='black' \
        --unlink-in-bin='black' \
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

# bpytop ------------------------------------------------------------------ {{{2

koopa_install_bpytop() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/bpytop' \
        --name='bpytop' \
        "$@"
}

koopa_uninstall_bpytop() { # {{{3
    koopa_uninstall_app \
        --name='bpytop' \
        --unlink-in-bin='bpytop' \
        "$@"
}

# broot ------------------------------------------------------------------- {{{2

koopa_install_broot() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/broot' \
        --name='broot' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_broot() { # {{{3
    koopa_uninstall_app \
        --name='broot' \
        --unlink-in-bin='broot' \
        "$@"
}

# bzip2 ------------------------------------------------------------------- {{{2

koopa_install_bzip2() { # {{{3
    koopa_install_app \
        --name='bzip2' \
        "$@"
}

koopa_uninstall_bzip2() { # {{{3
    koopa_uninstall_app \
        --name='bzip2' \
        "$@"
}

# chemacs ----------------------------------------------------------------- {{{2

# FIXME Need to version pin this.
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

# FIXME When installing, we now hit this error:
# /opt/koopa/lang/shell/bash/functions/common/fs/core.sh:448: /opt/koopa/opt/coreutils/bin/ln: No such file or directory

koopa_install_coreutils() { # {{{3
    # """
    # Consider adding '--activate-opt=attr' here.
    # """
    local install_args
    install_args=(
        '--name=coreutils'
        '--link-in-bin=bin/['
        '--link-in-bin=bin/b2sum'
        '--link-in-bin=bin/base32'
        '--link-in-bin=bin/base64'
        '--link-in-bin=bin/basename'
        '--link-in-bin=bin/basenc'
        '--link-in-bin=bin/cat'
        '--link-in-bin=bin/chcon'
        '--link-in-bin=bin/chgrp'
        '--link-in-bin=bin/chmod'
        '--link-in-bin=bin/chown'
        '--link-in-bin=bin/chroot'
        '--link-in-bin=bin/cksum'
        '--link-in-bin=bin/comm'
        '--link-in-bin=bin/cp'
        '--link-in-bin=bin/csplit'
        '--link-in-bin=bin/cut'
        '--link-in-bin=bin/date'
        '--link-in-bin=bin/dd'
        '--link-in-bin=bin/df'
        '--link-in-bin=bin/dir'
        '--link-in-bin=bin/dircolors'
        '--link-in-bin=bin/dirname'
        '--link-in-bin=bin/du'
        '--link-in-bin=bin/echo'
        '--link-in-bin=bin/env'
        '--link-in-bin=bin/expand'
        '--link-in-bin=bin/expr'
        '--link-in-bin=bin/factor'
        '--link-in-bin=bin/false'
        '--link-in-bin=bin/fmt'
        '--link-in-bin=bin/fold'
        '--link-in-bin=bin/groups'
        '--link-in-bin=bin/head'
        '--link-in-bin=bin/hostid'
        '--link-in-bin=bin/id'
        '--link-in-bin=bin/install'
        '--link-in-bin=bin/join'
        '--link-in-bin=bin/kill'
        '--link-in-bin=bin/link'
        '--link-in-bin=bin/ln'
        '--link-in-bin=bin/logname'
        '--link-in-bin=bin/ls'
        '--link-in-bin=bin/md5sum'
        '--link-in-bin=bin/mkdir'
        '--link-in-bin=bin/mkfifo'
        '--link-in-bin=bin/mknod'
        '--link-in-bin=bin/mktemp'
        '--link-in-bin=bin/mv'
        '--link-in-bin=bin/nice'
        '--link-in-bin=bin/nl'
        '--link-in-bin=bin/nohup'
        '--link-in-bin=bin/nproc'
        '--link-in-bin=bin/numfmt'
        '--link-in-bin=bin/od'
        '--link-in-bin=bin/paste'
        '--link-in-bin=bin/pathchk'
        '--link-in-bin=bin/pinky'
        '--link-in-bin=bin/pr'
        '--link-in-bin=bin/printenv'
        '--link-in-bin=bin/printf'
        '--link-in-bin=bin/ptx'
        '--link-in-bin=bin/pwd'
        '--link-in-bin=bin/readlink'
        '--link-in-bin=bin/realpath'
        '--link-in-bin=bin/rm'
        '--link-in-bin=bin/rmdir'
        '--link-in-bin=bin/runcon'
        '--link-in-bin=bin/seq'
        '--link-in-bin=bin/sha1sum'
        '--link-in-bin=bin/sha224sum'
        '--link-in-bin=bin/sha256sum'
        '--link-in-bin=bin/sha384sum'
        '--link-in-bin=bin/sha512sum'
        '--link-in-bin=bin/shred'
        '--link-in-bin=bin/shuf'
        '--link-in-bin=bin/sleep'
        '--link-in-bin=bin/sort'
        '--link-in-bin=bin/split'
        '--link-in-bin=bin/stat'
        '--link-in-bin=bin/stdbuf'
        '--link-in-bin=bin/stty'
        '--link-in-bin=bin/sum'
        '--link-in-bin=bin/sync'
        '--link-in-bin=bin/tac'
        '--link-in-bin=bin/tail'
        '--link-in-bin=bin/tee'
        '--link-in-bin=bin/test'
        '--link-in-bin=bin/timeout'
        '--link-in-bin=bin/touch'
        '--link-in-bin=bin/tr'
        '--link-in-bin=bin/true'
        '--link-in-bin=bin/truncate'
        '--link-in-bin=bin/tsort'
        '--link-in-bin=bin/tty'
        '--link-in-bin=bin/uname'
        '--link-in-bin=bin/unexpand'
        '--link-in-bin=bin/uniq'
        '--link-in-bin=bin/unlink'
        '--link-in-bin=bin/uptime'
        '--link-in-bin=bin/users'
        '--link-in-bin=bin/vdir'
        '--link-in-bin=bin/wc'
        '--link-in-bin=bin/who'
        '--link-in-bin=bin/whoami'
        '--link-in-bin=bin/yes'
    )
    koopa_install_gnu_app "${install_args[@]}" "$@"
}

koopa_uninstall_coreutils() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name=coreutils'
        '--unlink-in-bin=['
        '--unlink-in-bin=b2sum'
        '--unlink-in-bin=base32'
        '--unlink-in-bin=base64'
        '--unlink-in-bin=basename'
        '--unlink-in-bin=basenc'
        '--unlink-in-bin=cat'
        '--unlink-in-bin=chcon'
        '--unlink-in-bin=chgrp'
        '--unlink-in-bin=chmod'
        '--unlink-in-bin=chown'
        '--unlink-in-bin=chroot'
        '--unlink-in-bin=cksum'
        '--unlink-in-bin=comm'
        '--unlink-in-bin=cp'
        '--unlink-in-bin=csplit'
        '--unlink-in-bin=cut'
        '--unlink-in-bin=date'
        '--unlink-in-bin=dd'
        '--unlink-in-bin=df'
        '--unlink-in-bin=dir'
        '--unlink-in-bin=dircolors'
        '--unlink-in-bin=dirname'
        '--unlink-in-bin=du'
        '--unlink-in-bin=echo'
        '--unlink-in-bin=env'
        '--unlink-in-bin=expand'
        '--unlink-in-bin=expr'
        '--unlink-in-bin=factor'
        '--unlink-in-bin=false'
        '--unlink-in-bin=fmt'
        '--unlink-in-bin=fold'
        '--unlink-in-bin=groups'
        '--unlink-in-bin=head'
        '--unlink-in-bin=hostid'
        '--unlink-in-bin=id'
        '--unlink-in-bin=install'
        '--unlink-in-bin=join'
        '--unlink-in-bin=kill'
        '--unlink-in-bin=link'
        '--unlink-in-bin=ln'
        '--unlink-in-bin=logname'
        '--unlink-in-bin=ls'
        '--unlink-in-bin=md5sum'
        '--unlink-in-bin=mkdir'
        '--unlink-in-bin=mkfifo'
        '--unlink-in-bin=mknod'
        '--unlink-in-bin=mktemp'
        '--unlink-in-bin=mv'
        '--unlink-in-bin=nice'
        '--unlink-in-bin=nl'
        '--unlink-in-bin=nohup'
        '--unlink-in-bin=nproc'
        '--unlink-in-bin=numfmt'
        '--unlink-in-bin=od'
        '--unlink-in-bin=paste'
        '--unlink-in-bin=pathchk'
        '--unlink-in-bin=pinky'
        '--unlink-in-bin=pr'
        '--unlink-in-bin=printenv'
        '--unlink-in-bin=printf'
        '--unlink-in-bin=ptx'
        '--unlink-in-bin=pwd'
        '--unlink-in-bin=readlink'
        '--unlink-in-bin=realpath'
        '--unlink-in-bin=rm'
        '--unlink-in-bin=rmdir'
        '--unlink-in-bin=runcon'
        '--unlink-in-bin=seq'
        '--unlink-in-bin=sha1sum'
        '--unlink-in-bin=sha224sum'
        '--unlink-in-bin=sha256sum'
        '--unlink-in-bin=sha384sum'
        '--unlink-in-bin=sha512sum'
        '--unlink-in-bin=shred'
        '--unlink-in-bin=shuf'
        '--unlink-in-bin=sleep'
        '--unlink-in-bin=sort'
        '--unlink-in-bin=split'
        '--unlink-in-bin=stat'
        '--unlink-in-bin=stdbuf'
        '--unlink-in-bin=stty'
        '--unlink-in-bin=sum'
        '--unlink-in-bin=sync'
        '--unlink-in-bin=tac'
        '--unlink-in-bin=tail'
        '--unlink-in-bin=tee'
        '--unlink-in-bin=test'
        '--unlink-in-bin=timeout'
        '--unlink-in-bin=touch'
        '--unlink-in-bin=tr'
        '--unlink-in-bin=true'
        '--unlink-in-bin=truncate'
        '--unlink-in-bin=tsort'
        '--unlink-in-bin=tty'
        '--unlink-in-bin=uname'
        '--unlink-in-bin=unexpand'
        '--unlink-in-bin=uniq'
        '--unlink-in-bin=unlink'
        '--unlink-in-bin=uptime'
        '--unlink-in-bin=users'
        '--unlink-in-bin=vdir'
        '--unlink-in-bin=wc'
        '--unlink-in-bin=who'
        '--unlink-in-bin=whoami'
        '--unlink-in-bin=yes'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# cpufetch ---------------------------------------------------------------- {{{2

koopa_install_cpufetch() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/cpufetch' \
        --name='cpufetch' \
        "$@"
}

koopa_uninstall_cpufetch() { # {{{3
    koopa_uninstall_app \
        --name='cpufetch' \
        --unlink-in-bin='cpufetch' \
        "$@"
}

# curl -------------------------------------------------------------------- {{{2

koopa_install_curl() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/curl' \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_uninstall_curl() { # {{{3
    koopa_uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        --unlink-in-bin='curl' \
        "$@"
}

# difftastic -------------------------------------------------------------- {{{2

koopa_install_difftastic() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/difft' \
        --name='difftastic' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_difftastic() { # {{{3
    koopa_uninstall_app \
        --name='difftastic' \
        --unlink-in-bin='difft' \
        "$@"
}

# dog --------------------------------------------------------------------- {{{2

koopa_install_dog() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/dog' \
        --name='dog' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_dog() { # {{{3
    koopa_uninstall_app \
        --name='dog' \
        --unlink-in-bin='dog' \
        "$@"
}

# du-dust ----------------------------------------------------------------- {{{2

koopa_install_du_dust() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/dust' \
        --name='du-dust' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_du_dust() { # {{{3
    koopa_uninstall_app \
        --name='du-dust' \
        --unlink-in-bin='dust' \
        "$@"
}

# dotfiles ---------------------------------------------------------------- {{{2

# FIXME Need to version pin this.
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
    local install_args
    install_args=(
        '--name-fancy=Emacs'
        '--name=emacs'
    )
    # Assume we're using Emacs cask by default on macOS.
    if ! koopa_is_macos
    then
        install_args+=('--link-in-bin=bin/emacs')
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_uninstall_emacs() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Emacs'
        '--name=emacs'
    )
    # Assume we're using Emacs cask by default on macOS.
    if ! koopa_is_macos
    then
        uninstall_args+=('--unlink-in-bin=emacs')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# ensembl-perl-api -------------------------------------------------------- {{{2

# FIXME Need to version pin this.
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

# exa --------------------------------------------------------------------- {{{2

koopa_install_exa() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/exa' \
        --name='exa' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_exa() { # {{{3
    koopa_uninstall_app \
        --name='exa' \
        --unlink-in-bin='exa' \
        "$@"
}

# fd-find ----------------------------------------------------------------- {{{2

koopa_install_fd_find() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/fd' \
        --name='fd-find' \
        "$@"
}

koopa_uninstall_fd_find() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='fd' \
        --name='fd-find' \
        "$@"
}

# findutils --------------------------------------------------------------- {{{2

koopa_install_findutils() { # {{{3
    local install_args
    install_args=(
        '--link-in-bin=bin/find'
        '--link-in-bin=bin/locate'
        '--link-in-bin=bin/updatedb'
        '--link-in-bin=bin/xargs'
        '--name=findutils'
    )
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
    koopa_install_gnu_app "${install_args[@]}" "$@"
}

koopa_uninstall_findutils() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name=findutils'
        '--unlink-in-bin=find'
        '--unlink-in-bin=locate'
        '--unlink-in-bin=updatedb'
        '--unlink-in-bin=xargs'
    )
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# fish -------------------------------------------------------------------- {{{2

koopa_install_fish() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/fish' \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa_uninstall_fish() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        --unlink-in-bin='fish' \
        "$@"
}

# flake8 ------------------------------------------------------------------ {{{2

koopa_install_flake8() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/flake8' \
        --name='flake8' \
        "$@"
}

koopa_uninstall_flake8() { # {{{3
    koopa_uninstall_app \
        --name='flake8' \
        --unlink-in-bin='flake8' \
        "$@"
}

# fltk -------------------------------------------------------------------- {{{2

koopa_install_fltk() { # {{{3
    koopa_install_app \
        --name-fancy='FLTK' \
        --name='fltk' \
        "$@"
}

koopa_uninstall_fltk() { # {{{3
    koopa_uninstall_app \
        --name-fancy='FLTK' \
        --name='fltk' \
        "$@"
}

# freetype ---------------------------------------------------------------- {{{2

koopa_install_freetype() { # {{{3
    koopa_install_gnu_app \
        --name='freetype' \
        -D '--enable-freetype-config' \
        -D '--enable-shared=yes' \
        -D '--enable-static=yes' \
        -D '--without-harfbuzz' \
        "$@"
}

koopa_uninstall_freetype() { # {{{3
    koopa_uninstall_app \
        --name='freetype' \
        "$@"
}

# fribidi ----------------------------------------------------------------- {{{2

koopa_install_fribidi() { # {{{3
    koopa_install_app \
        --name='fribidi' \
        "$@"
}

koopa_uninstall_fribidi() { # {{{3
    koopa_uninstall_app \
        --name='fribidi' \
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

koopa_uninstall_fzf() { # {{{3
    koopa_uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        --unlink-in-bin='fzf' \
        "$@"
}

# gawk -------------------------------------------------------------------- {{{2

koopa_install_gawk() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/awk' \
        --name='gawk' \
        "$@"
}

koopa_uninstall_gawk() { # {{{3
    koopa_uninstall_app \
        --name='gawk' \
        --unlink-in-bin='awk' \
        "$@"
}

# gcc --------------------------------------------------------------------- {{{2

# > koopa_install_gcc() { # {{{3
# >     koopa_install_app \
# >         --name-fancy='GCC' \
# >         --name='gcc' \
# >         "$@"
# > }

# > koopa_uninstall_gcc() { # {{{3
# >     koopa_uninstall_app \
# >         --name-fancy='GCC' \
# >         --name='gcc' \
# >         "$@"
# > }

# gdal -------------------------------------------------------------------- {{{2

# > koopa_install_gdal() { # {{{3
# >     koopa_install_app \
# >         --name-fancy='GDAL' \
# >         --name='gdal' \
# >         "$@"
# > }

# > koopa_uninstall_gdal() { # {{{3
# >     koopa_uninstall_app \
# >         --name-fancy='GDAL' \
# >         --name='gdal' \
# >         "$@"
# > }

# geos -------------------------------------------------------------------- {{{2

# > koopa_install_geos() { # {{{3
# >     koopa_install_app \
# >         --name-fancy='GEOS' \
# >         --name='geos' \
# >         "$@"
# > }

# > koopa_uninstall_geos() { # {{{3
# >     koopa_uninstall_app \
# >         --name-fancy='GEOS' \
# >         --name='geos' \
# >         "$@"
# > }

# gettext ----------------------------------------------------------------- {{{2

koopa_install_gettext() { # {{{3
    koopa_install_gnu_app \
        --name='gettext' \
        "$@"
}

koopa_uninstall_gettext() { # {{{3
    koopa_uninstall_app \
        --name='gettext' \
        "$@"
}

# git --------------------------------------------------------------------- {{{2

koopa_install_git() { # {{{3
    local install_args
    install_args=(
        '--link-in-bin=bin/git'
        '--name-fancy=Git'
        '--name=git'
    )
    if koopa_is_macos
    then
        install_args+=(
            '--link-in-bin=bin/git-credential-osxkeychain'
        )
    fi
    koopa_install_app "${install_args[@]}" "$@"
}

koopa_uninstall_git() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name-fancy=Git'
        '--name=git'
        '--unlink-in-bin=git'
    )
    if koopa_is_macos
    then
        uninstall_args+=(
            '--unlink-in-bin=git-credential-osxkeychain'
        )
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
}

# glances ----------------------------------------------------------------- {{{2

koopa_install_glances() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/glances' \
        --name='glances' \
        "$@"
}

koopa_uninstall_glances() { # {{{3
    koopa_uninstall_app \
        --name='glances' \
        --unlink-in-bin='glances' \
        "$@"
}

# gmp --------------------------------------------------------------------- {{{2

koopa_install_gmp() { # {{{3
    koopa_install_app \
        --name='gmp' \
        "$@"
}

koopa_uninstall_gmp() { # {{{3
    koopa_uninstall_app \
        --name='gmp' \
        "$@"
}

# gnupg ------------------------------------------------------------------- {{{2

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

# gnutls ------------------------------------------------------------------ {{{2

koopa_install_gnutls() { # {{{1
    koopa_install_app \
        --activate-opt='gmp' \
        --activate-opt='libtasn1' \
        --activate-opt='libunistring' \
        --activate-opt='nettle' \
        --installer='gnupg-gcrypt' \
        --name='gnutls' \
        -D '--without-p11-kit' \
        "$@"
}

koopa_uninstall_gnutls() { # {{{3
    koopa_uninstall_app \
        --name='gnutls' \
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

koopa_uninstall_go() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        --unlink-in-bin='go' \
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
        --activate-opt='pcre2' \
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
        --link-in-bin='bin/groff' \
        --name='groff' \
        "$@"
}

koopa_uninstall_groff() { # {{{3
    koopa_uninstall_app \
        --name='groff' \
        --unlink-in-bin='groff' \
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

# gzip -------------------------------------------------------------------- {{{2

koopa_install_gzip() { # {{{3
    koopa_install_gnu_app \
        --name='gzip' \
        "$@"
}

koopa_uninstall_gzip() { # {{{3
    koopa_uninstall_app \
        --name='gzip' \
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
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        "$@"
}

koopa_uninstall_haskell_stack() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
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

koopa_uninstall_htop() { # {{{3
    koopa_uninstall_app \
        --name='htop' \
        --unlink-in-bin='htop' \
        "$@"
}

# hyperfine --------------------------------------------------------------- {{{2

koopa_install_hyperfine() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/hyperfine' \
        --name='hyperfine' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_hyperfine() { # {{{3
    koopa_uninstall_app \
        --name='hyperfine' \
        --unlink-in-bin='hyperfine' \
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
        --link-in-bin='bin/magick' \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_uninstall_imagemagick() { # {{{3
    koopa_uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        --link-in-bin='magick' \
        "$@"
}

# jpeg -------------------------------------------------------------------- {{{2

# NOTE Consider renaming this to 'libjpeg'.

koopa_install_jpeg() { # {{{3
    koopa_install_app \
        --name='jpeg' \
        "$@"
}

koopa_uninstall_jpeg() { # {{{3
    koopa_uninstall_app \
        --name='jpeg' \
        "$@"
}

# jq ---------------------------------------------------------------------- {{{2

koopa_install_jq() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/jq' \
        --name='jq' \
        "$@"
}

koopa_uninstall_jq() { # {{{3
    koopa_uninstall_app \
        --name='jq' \
        --unlink-in-bin='jq' \
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

koopa_install_julia_packages() { # {{{3
    koopa_install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_uninstall_julia_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        "$@"
}

koopa_update_julia_packages() { # {{{3
    koopa_install_julia_packages "$@"
}

# lapack ------------------------------------------------------------------ {{{2

koopa_install_lapack() { # {{{3
    koopa_install_app \
        --name-fancy='LAPACK' \
        --name='lapack' \
        "$@"
}

koopa_uninstall_lapack() { # {{{3
    koopa_uninstall_app \
        --name-fancy='LAPACK' \
        --name='lapack' \
        "$@"
}

# less -------------------------------------------------------------------- {{{2

koopa_install_less() { # {{{3
    koopa_install_gnu_app \
        --activate-opt='ncurses' \
        --activate-opt='pcre2' \
        --link-in-bin='bin/less' \
        --name='less' \
        "$@"
}

koopa_uninstall_less() { # {{{3
    koopa_uninstall_app \
        --name='autoconf' \
        --unlink-in-bin='less' \
        "$@"
}

# lesspipe ---------------------------------------------------------------- {{{2

koopa_install_lesspipe() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/lesspipe.sh' \
        --name='lesspipe' \
        "$@"
}

koopa_uninstall_lesspipe() { # {{{3
    koopa_uninstall_app \
        --name='lesspipe' \
        --unlink-in-bin='lesspipe.sh' \
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

# libffi ------------------------------------------------------------------ {{{2

koopa_install_libffi() { # {{{3
    koopa_install_app \
        --name='libffi' \
        "$@"
}

koopa_uninstall_libffi() { # {{{3
    koopa_uninstall_app \
        --name='libffi' \
        "$@"
}

# libgeotiff -------------------------------------------------------------- {{{2

koopa_install_libgeotiff() { # {{{3
    koopa_install_app \
        --name='libgeotiff' \
        "$@"
}

koopa_uninstall_libgeotiff() { # {{{3
    koopa_uninstall_app \
        --name='libgeotiff' \
        "$@"
}

# libgit2 ----------------------------------------------------------------- {{{2

koopa_install_libgit2() { # {{{3
    koopa_install_app \
        --name='libgit2' \
        "$@"
}

koopa_uninstall_libgit2() { # {{{3
    koopa_uninstall_app \
        --name='libgit2' \
        "$@"
}

# libidn ---------------------------------------------------------------- {{{2

koopa_install_libidn() { # {{{3
    koopa_install_gnu_app \
        --name='libidn' \
        "$@"
}

koopa_uninstall_libidn() { # {{{3
    koopa_uninstall_app \
        --name='libidn' \
        "$@"
}

# libjpeg-turbo ----------------------------------------------------------- {{{2

koopa_install_libjpeg_turbo() { # {{{3
    koopa_install_app \
        --name='libjpeg-turbo' \
        "$@"
}

koopa_uninstall_libjpeg_turbo() { # {{{3
    koopa_uninstall_app \
        --name='libjpeg-turbo' \
        "$@"
}

# libpipeline ------------------------------------------------------------- {{{2

koopa_install_libpipeline() { # {{{3
    koopa_install_gnu_app \
        --name='libpipeline' \
        "$@"
}

koopa_uninstall_libpipeline() { # {{{3
    koopa_uninstall_app \
        --name='libpipeline' \
        "$@"
}

# libpng ------------------------------------------------------------------ {{{2

koopa_install_libpng() { # {{{3
    koopa_install_app \
        --name='libpng' \
        "$@"
}

koopa_uninstall_libpng() { # {{{3
    koopa_uninstall_app \
        --name='libpng' \
        "$@"
}

# libssh2 ----------------------------------------------------------------- {{{2

koopa_install_libssh2() { # {{{3
    koopa_install_app \
        --name='libssh2' \
        "$@"
}

koopa_uninstall_libssh2() { # {{{3
    koopa_uninstall_app \
        --name='libssh2' \
        "$@"
}

# libtasn1 ---------------------------------------------------------------- {{{2

koopa_install_libtasn1() { # {{{3
    koopa_install_gnu_app \
        --name='libtasn1' \
        "$@"
}

koopa_uninstall_libtasn1() { # {{{3
    koopa_uninstall_app \
        --name='libtasn1' \
        "$@"
}

# libtiff ----------------------------------------------------------------- {{{2

koopa_install_libtiff() { # {{{3
    koopa_install_app \
        --name='libtiff' \
        "$@"
}

koopa_uninstall_libtiff() { # {{{3
    koopa_uninstall_app \
        --name='libtiff' \
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

# libunistring ------------------------------------------------------------ {{{2

koopa_install_libunistring() { # {{{3
    koopa_install_gnu_app \
        --name='libunistring' \
        "$@"
}

koopa_uninstall_libunistring() { # {{{3
    koopa_uninstall_app \
        --name='libunistring' \
        "$@"
}

# libuv ------------------------------------------------------------------- {{{2

koopa_install_libuv() { # {{{3
    koopa_install_app \
        --name='libuv' \
        "$@"
}

koopa_uninstall_libuv() { # {{{3
    koopa_uninstall_app \
        --name='libuv' \
        "$@"
}

# libxml2 ----------------------------------------------------------------- {{{2

koopa_install_libxml2() { # {{{3
    koopa_install_app \
        --name='libxml2' \
        "$@"
}

koopa_uninstall_libxml2() { # {{{3
    koopa_uninstall_app \
        --name='libxml2' \
        "$@"
}

# libzip ------------------------------------------------------------------ {{{2

koopa_install_libzip() { # {{{3
    koopa_install_app \
        --name='libzip' \
        "$@"
}

koopa_uninstall_libzip() { # {{{3
    koopa_uninstall_app \
        --name='libzip' \
        "$@"
}

# lua --------------------------------------------------------------------- {{{2

koopa_install_lua() { # {{{3
    koopa_install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa_uninstall_lua() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

# luarocks ---------------------------------------------------------------- {{{2

koopa_install_luarocks() { # {{{3
    koopa_install_app \
        --name='luarocks' \
        "$@"
}

koopa_uninstall_luarocks() { # {{{3
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

# lzma -------------------------------------------------------------------- {{{2

koopa_install_lzma() { # {{{3
    koopa_install_app \
        --name-fancy='LZMA' \
        --name='lzma' \
        "$@"
}

koopa_uninstall_lzma() { # {{{3
    koopa_uninstall_app \
        --name-fancy='LZMA' \
        --name='lzma' \
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

# mcfly ------------------------------------------------------------------- {{{2

koopa_install_mcfly() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/mcfly' \
        --name='mcfly' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_mcfly() { # {{{3
    koopa_uninstall_app \
        --name='mcfly' \
        --unlink-in-bin='mcfly' \
        "$@"
}

# meson ------------------------------------------------------------------- {{{2

koopa_install_meson() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
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

koopa_uninstall_neofetch() { # {{{3
    koopa_uninstall_app \
        --name='neofetch' \
        --unlink-in-bin='neofetch' \
        "$@"
}

# neovim ------------------------------------------------------------------ {{{2

koopa_install_neovim() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/nvim' \
        --name='neovim' \
        "$@"
}

koopa_uninstall_neovim() { # {{{3
    koopa_uninstall_app \
        --name='neovim' \
        --unlink-in-bin='nvim' \
        "$@"
}

# nettle ------------------------------------------------------------------ {{{2

koopa_install_nettle() { # {{{3
    # """
    # Need to make sure libhogweed installs.
    # - https://stackoverflow.com/questions/9508851/how-to-compile-gnutls
    # - https://noknow.info/it/os/install_nettle_from_source
    # - https://www.linuxfromscratch.org/blfs/view/svn/postlfs/nettle.html
    # - https://stackoverflow.com/questions/7965990
    # - https://gist.github.com/morgant/1753095
    # """
    koopa_install_gnu_app \
        --activate-opt='gmp' \
        --name='nettle' \
        -D --disable-dependency-tracking \
        -D --enable-mini-gmp \
        -D --enable-shared \
        "$@"
}

koopa_uninstall_nettle() { # {{{3
    koopa_uninstall_app \
        --name='nettle' \
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

koopa_uninstall_nim() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        --unlink-in-bin='nim' \
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

koopa_uninstall_nim_packages() { # {{{3
    koopa_uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        --unlink-in-bin='markdown' \
        "$@"
}

koopa_update_nim_packages() { # {{{3
    koopa_install_nim_packages "$@"
}

# ninja ------------------------------------------------------------------- {{{2

koopa_install_ninja() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}

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

koopa_uninstall_node() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        --unlink-in-bin='node' \
        "$@"
}

# node-binary ------------------------------------------------------------- {{{2

koopa_install_node_binary() { # {{{3
    koopa_install_app \
        --installer='node-binary' \
        --link-in-bin='bin/node' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_uninstall_node_binary() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        --unlink-in-bin='node' \
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

koopa_uninstall_node_packages() { # {{{3
    koopa_uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        --unlink-in-bin='bash-language-server' \
        --unlink-in-bin='gtop' \
        --unlink-in-bin='npm' \
        --unlink-in-bin='prettier' \
        "$@"
}

koopa_update_node_packages() { # {{{3
    koopa_install_node_packages "$@"
}

# oniguruma --------------------------------------------------------------- {{{2

koopa_install_oniguruma() { # {{{3
    koopa_install_app \
        --name='oniguruma' \
        "$@"
}

koopa_uninstall_oniguruma() { # {{{3
    koopa_uninstall_app \
        --name='oniguruma' \
        "$@"
}

# openblas ---------------------------------------------------------------- {{{2

koopa_install_openblas() { # {{{3
    koopa_install_app \
        --name-fancy='OpenBLAS' \
        --name='openblas' \
        "$@"
}

koopa_uninstall_openblas() { # {{{3
    koopa_uninstall_app \
        --name-fancy='OpenBLAS' \
        --name='openblas' \
        "$@"
}

# openjdk ----------------------------------------------------------------- {{{2

koopa_install_openjdk() { # {{{3
    koopa_install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        "$@"
}

koopa_uninstall_openjdk() { # {{{3
    local uninstall_args
    uninstall_args=(
        '--name-fancy=OpenJDK'
        '--name=openjdk'
    )
    # Reset 'default-java' on Linux, when possible.
    if koopa_is_linux
    then
        uninstall_args+=('--platform=linux')
    fi
    koopa_uninstall_app "${uninstall_args[@]}" "$@"
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

# pandoc ------------------------------------------------------------------ {{{2

koopa_install_pandoc() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/pandoc' \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        "$@"
    return 0
}

koopa_uninstall_pandoc() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Pandoc' \
        --name='pandoc' \
        --unlink-in-bin='pandoc' \
        "$@"
}

# parallel ---------------------------------------------------------------- {{{2

koopa_install_parallel() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/parallel' \
        --name='parallel' \
        "$@"
}

koopa_uninstall_parallel() { # {{{3
    koopa_uninstall_app \
        --name='parallel' \
        --unlink-in-bin='parallel' \
        "$@"
}

# password-store ---------------------------------------------------------- {{{2

koopa_install_password_store() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/pass' \
        --name='password-store' \
        "$@"
}

koopa_uninstall_password_store() { # {{{3
    koopa_uninstall_app \
        --name='password-store' \
        --unlink-in-bin='pass' \
        "$@"
}

# patch ------------------------------------------------------------------- {{{2

koopa_install_patch() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/patch' \
        --name='patch' \
        "$@"
}

koopa_uninstall_patch() { # {{{3
    koopa_uninstall_app \
        --name='patch' \
        --unlink-in-bin='patch' \
        "$@"
}

# pcre -------------------------------------------------------------------- {{{2

koopa_install_pcre() { # {{{3
    koopa_install_app \
        --name-fancy='PCRE' \
        --name='pcre' \
        "$@"
}

koopa_uninstall_pcre() { # {{{3
    koopa_uninstall_app \
        --name-fancy='PCRE' \
        --name='pcre' \
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

koopa_uninstall_perl_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        --unlink-in-bin='ack' \
        --unlink-in-bin='cpanm' \
        --unlink-in-bin='rename' \
        "$@"
    return 0
}

koopa_update_perl_packages() { # {{{3
    koopa_install_perl_packages "$@"
}

# perlbrew ---------------------------------------------------------------- {{{2

# FIXME Need to version pin this.
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

# pipx -------------------------------------------------------------------- {{{2

koopa_install_pipx() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pipx' \
        --name='pipx' \
        "$@"
}

koopa_uninstall_pipx() { # {{{3
    koopa_uninstall_app \
        --name='pipx' \
        --unlink-in-bin='pipx' \
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

# procs ------------------------------------------------------------------- {{{2

koopa_install_procs() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/procs' \
        --name='procs' \
        --installer='rust-package' \
        "$@"
}

koopa_uninstall_procs() { # {{{3
    koopa_uninstall_app \
        --name='procs' \
        --unlink-in-bin='procs' \
        "$@"
}

# proj -------------------------------------------------------------------- {{{2

# > koopa_install_proj() { # {{{3
# >     koopa_install_app \
# >         --name-fancy='PROJ' \
# >         --name='proj' \
# >         "$@"
# > }

# > koopa_uninstall_proj() { # {{{3
# >     koopa_uninstall_app \
# >         --name-fancy='PROJ' \
# >         --name='proj' \
# >         "$@"
# > }

# pyenv ------------------------------------------------------------------- {{{2

# FIXME Need to version pin this.
koopa_install_pyenv() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/pyenv' \
        --name='pyenv' \
        --version='rolling' \
        "$@"
}

koopa_uninstall_pyenv() { # {{{3
    koopa_uninstall_app \
        --name='pyenv' \
        --unlink-in-bin='pyenv' \
        "$@"
}

# pyflakes ---------------------------------------------------------------- {{{2

koopa_install_pyflakes() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pyflakes' \
        --name='pyflakes' \
        "$@"
}

koopa_uninstall_pyflakes() { # {{{3
    koopa_uninstall_app \
        --name='pyflakes' \
        --unlink-in-bin='pyflakes' \
        "$@"
}

# pylint ------------------------------------------------------------------ {{{2

koopa_install_pylint() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pylint' \
        --name='pylint' \
        "$@"
}

koopa_uninstall_pylint() { # {{{3
    koopa_uninstall_app \
        --name='pylint' \
        --unlink-in-bin='pylint' \
        "$@"
}

# pytest ------------------------------------------------------------------ {{{2

koopa_install_pytest() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/pytest' \
        --name='pytest' \
        "$@"
}

koopa_uninstall_pytest() { # {{{3
    koopa_uninstall_app \
        --name='pytest' \
        --unlink-in-bin='pytest' \
        "$@"
}

# python ------------------------------------------------------------------ {{{2

koopa_install_python() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/python3' \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_uninstall_python() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        --unlink-in-bin='python3' \
        "$@"
}

# r ----------------------------------------------------------------------- {{{2

koopa_install_r() { # {{{3
    local install_args
    install_args=(
        '--name-fancy=R'
        '--name=r'
    )
    if ! koopa_is_macos
    then
        # Assuming usage of R CRAN binary Homebrew cask.
        install_args+=(
            '--link-in-bin=bin/R'
            '--link-in-bin=bin/Rscript'
        )
    fi
    koopa_install_app \
        "${install_args[@]}" \
        "$@"
}

koopa_uninstall_r() { # {{{3
    koopa_uninstall_app \
        --name-fancy='R' \
        --name='r' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript'
        "$@"
}

# r-devel ----------------------------------------------------------------- {{{2

koopa_install_r_devel() { # {{{3
    # """
    # The 'R-devel' link is handled inside the installer script.
    # """
    koopa_install_app \
        --installer='r' \
        --name-fancy='R-devel' \
        --name='r-devel' \
        "$@"
}

koopa_uninstall_r_devel() { # {{{3
    koopa_uninstall_app \
        --name-fancy='R-devel' \
        --name='r-devel' \
        --unlink-in-bin='R-devel' \
        "$@"
}

# ranger-fm --------------------------------------------------------------- {{{2

koopa_install_ranger_fm() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --link-in-bin='bin/ranger' \
        --name='ranger-fm' \
        "$@"
}

koopa_uninstall_ranger_fm() { # {{{3
    koopa_uninstall_app \
        --name='ranger-fm' \
        --unlink-in-bin='ranger' \
        "$@"
}

# r-cmd-check ------------------------------------------------------------- {{{2

# FIXME Need to version pin this.
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

# FIXME Need to version pin this.
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

# readline ---------------------------------------------------------------- {{{2

koopa_install_readline() { # {{{3
    # """
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     readline.rb
    # """
    koopa_install_gnu_app \
        --activate-opt='ncurses' \
        --name='readline' \
        -D '--enable-shared' \
        -D '--enable-static' \
        -D '--with-curses' \
        "$@"
}

koopa_uninstall_readline() { # {{{3
    koopa_uninstall_app \
        --name='readline' \
        "$@"
}

# ripgrep ----------------------------------------------------------------- {{{2

koopa_install_ripgrep() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/rg' \
        --name='ripgrep' \
        "$@"
}

koopa_uninstall_ripgrep() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='rg' \
        --name='ripgrep' \
        "$@"
}

# ripgrep-all ------------------------------------------------------------- {{{2

# > koopa_install_ripgrep_all() { # {{{1
# >     koopa_install_app \
# >         --installer='rust-package' \
# >         --link-in-bin='bin/rga' \
# >         --name='ripgrep-all' \
# >         "$@"
# > }

# > koopa_uninstall_ripgrep_all() { # {{{1
# >     koopa_uninstall_app \
# >         --unlink-in-bin='rga' \
# >         --name='ripgrep-all' \
# >         "$@"
# > }

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

koopa_uninstall_ruby() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        --unlink-in-bin='gem' \
        --unlink-in-bin='ruby' \
        "$@"
}

# ruby-packages ----------------------------------------------------------- {{{2

koopa_install_ruby_packages() { # {{{3
    koopa_install_app_packages \
        --link-in-bin='bin/bashcov' \
        --link-in-bin='bin/bundle' \
        --link-in-bin='bin/bundler' \
        --link-in-bin='bin/colorls' \
        --link-in-bin='bin/ronn' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_uninstall_ruby_packages() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        --unlink-in-bin='bashcov' \
        --unlink-in-bin='bundle' \
        --unlink-in-bin='bundler' \
        --unlink-in-bin='colorls' \
        --unlink-in-bin='ronn' \
        "$@"
}

koopa_update_ruby_packages() {  # {{{3
    koopa_install_ruby_packages "$@"
}

# rust -------------------------------------------------------------------- {{{2

koopa_install_rust() { # {{{3
    koopa_install_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_uninstall_rust() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

# scons ------------------------------------------------------------------- {{{2

koopa_install_scons() { # {{{3
    koopa_install_app \
        --installer='python-venv' \
        --name-fancy='SCONS' \
        --name='scons' \
        "$@"
}

koopa_uninstall_scons() { # {{{3
    koopa_uninstall_app \
        --name-fancy='SCONS' \
        --name='scons' \
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

# serf -------------------------------------------------------------------- {{{2

koopa_install_serf() { # {{{3
    koopa_install_app \
        --name-fancy='Apache Serf' \
        --name='serf' \
        "$@"
}

koopa_uninstall_serf() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Apache Serf' \
        --name='serf' \
        "$@"
}

# (shellcheck) ------------------------------------------------------------ {{{2

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

koopa_install_shunit2() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/shunit2' \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa_uninstall_shunit2() { # {{{3
    koopa_uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        --unlink-in-bin='shunit2' \
        "$@"
}

# singularity ------------------------------------------------------------- {{{2

koopa_install_singularity() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/singularity' \
        --name='singularity' \
        "$@"
}

koopa_uninstall_singularity() { # {{{3
    koopa_uninstall_app \
        --name='singularity' \
        --unlink-in-bin='singularity' \
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

# starship ---------------------------------------------------------------- {{{2

koopa_install_starship() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/starship' \
        --name='starship' \
        "$@"
}

koopa_uninstall_starship() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='starship' \
        --name='starship' \
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

# FIXME This is having sqlite link issues on Ubuntu.
# > svn --version --verbose

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
# FIXME Need to link the 'pytagsXXX' binary here...
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

# tcl-tk ------------------------------------------------------------------ {{{2

koopa_install_tcl_tk() { # {{{3
    koopa_install_app \
        --name-fancy='Tcl/Tk' \
        --name='tcl-tk' \
        "$@"
}

koopa_uninstall_tcl_tk() { # {{{3
    koopa_uninstall_app \
        --name-fancy='Tcl/Tk' \
        --name='tcl-tk' \
        "$@"
}

# tealdeer ---------------------------------------------------------------- {{{2

koopa_install_tealdeer() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/tldr' \
        --name='tealdeer' \
        "$@"
}

koopa_uninstall_tealdeer() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='tldr' \
        --name='tealdeer' \
        "$@"
}

# texinfo ----------------------------------------------------------------- {{{2

koopa_install_texinfo() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/pdftexi2dvi' \
        --link-in-bin='bin/pod2texi' \
        --link-in-bin='bin/texi2any' \
        --link-in-bin='bin/texi2dvi' \
        --link-in-bin='bin/texi2pdf' \
        --link-in-bin='bin/texindex' \
        --name='texinfo' \
        "$@"
}

koopa_uninstall_texinfo() { # {{{3
    koopa_uninstall_app \
        --name='texinfo' \
        --unlink-in-bin='pdftexi2dvi' \
        --unlink-in-bin='pod2texi' \
        --unlink-in-bin='texi2any' \
        --unlink-in-bin='texi2dvi' \
        --unlink-in-bin='texi2pdf' \
        --unlink-in-bin='texindex' \
        "$@"
}

# the-silver-searcher ----------------------------------------------------- {{{2

# > koopa_install_the_silver_searcher() { # {{{3
# >     koopa_install_app \
# >         --link-in-bin='bin/ag' \
# >         --name='the-silver-searcher' \
# >         "$@"
# > }

# > koopa_uninstall_the_silver_searcher() { # {{{3
# >     koopa_uninstall_app \
# >         --name='the-silver-searcher' \
# >         --unlink-in-bin='ag' \
# >         "$@"
# > }

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

# tokei ------------------------------------------------------------------- {{{2

koopa_install_tokei() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/tokei' \
        --name='tokei' \
        "$@"
}

koopa_uninstall_tokei() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='tokei' \
        --name='tokei' \
        "$@"
}

# tree -------------------------------------------------------------------- {{{2

koopa_install_tree() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/tree' \
        --name='tree' \
        "$@"
}

koopa_uninstall_tree() { # {{{3
    koopa_uninstall_app \
        --name='tree' \
        --unlink-in-bin='tree' \
        "$@"
}

# udunits ----------------------------------------------------------------- {{{2

koopa_install_udunits() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/udunits2' \
        --name='udunits' \
        "$@"
}

koopa_uninstall_udunits() { # {{{3
    koopa_uninstall_app \
        --name='udunits' \
        --unlink-in-bin='udunits2' \
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

# which ------------------------------------------------------------------- {{{2

koopa_install_which() { # {{{3
    koopa_install_gnu_app \
        --link-in-bin='bin/which' \
        --name='which' \
        "$@"
}

koopa_uninstall_which() { # {{{3
    koopa_uninstall_app \
        --name='which' \
        --unlink-in-bin='which' \
        "$@"
}

# xsv ------------------------------------------------------------------- {{{2

koopa_install_xsv() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/xsv' \
        --name='xsv' \
        "$@"
}

koopa_uninstall_xsv() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='xsv' \
        --name='xsv' \
        "$@"
}

# xz ---------------------------------------------------------------------- {{{2

koopa_install_xz() { # {{{3
    koopa_install_app \
        --link-in-bin='bin/xz' \
        --name='xz' \
        "$@"
}

koopa_uninstall_xz() { # {{{3
    koopa_uninstall_app \
        --name='xz' \
        --unlink-in-bin='xz' \
        "$@"
}

# zlib -------------------------------------------------------------------- {{{2

koopa_install_zlib() { # {{{3
    koopa_install_app \
        --name='zlib' \
        "$@"
}

koopa_uninstall_zlib() { # {{{3
    koopa_uninstall_app \
        --name='zlib' \
        "$@"
}

# zoxide ------------------------------------------------------------------ {{{2

koopa_install_zoxide() { # {{{1
    koopa_install_app \
        --installer='rust-package' \
        --link-in-bin='bin/zoxide' \
        --name='zoxide' \
        "$@"
}

koopa_uninstall_zoxide() { # {{{1
    koopa_uninstall_app \
        --unlink-in-bin='zoxide' \
        --name='zoxide' \
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

# zstd -------------------------------------------------------------------- {{{2

koopa_install_zstd() { # {{{3
    koopa_install_app \
        --name='zstd' \
        "$@"
}

koopa_uninstall_zstd() { # {{{3
    koopa_uninstall_app \
        --name='zstd' \
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
        --no-prefix-check \
        --prefix="$(koopa_homebrew_prefix)" \
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

# FIXME Rework without declaring version here.
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

# FIXME Consider renaming version to 'latest' here instead.
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

# FIXME Consider renaming version to 'latest' here instead.
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

# FIXME Consider renaming version to 'latest' here instead.
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

# FIXME Consider renaming version to 'latest' here instead.
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
