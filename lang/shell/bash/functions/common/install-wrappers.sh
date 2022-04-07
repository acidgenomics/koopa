#!/usr/bin/env bash

# FIXME Need to ensure that unlinkers match.

koopa_install_anaconda() { # {{{1
    koopa_install_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}

koopa_install_armadillo() { # {{{1
    koopa_install_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}

koopa_install_autoconf() { # {{{1
    local install_args
    install_args=('--name=autoconf')
    # m4 is required for automake to build.
    if koopa_is_macos
    then
        install_args+=('--activate-homebrew-opt=m4')
    fi
    koopa_install_gnu_app "${install_args[@]}" "$@"
}

koopa_install_automake() { # {{{1
    koopa_install_gnu_app \
        --activate-opt='autoconf' \
        --name='automake' \
        "$@"
}

koopa_install_bash() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/bash' \
        --name-fancy='Bash' \
        --name='bash' \
        "$@"
}

koopa_install_binutils() { # {{{1
    koopa_install_gnu_app \
        --name='binutils' \
        "$@"
}

koopa_install_boost() { # {{{1
    koopa_install_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}

koopa_install_chemacs() { # {{{1
    koopa_install_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        --version='rolling' \
        "$@"
}

koopa_install_cmake() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/cmake' \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
}

koopa_install_conda() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/conda' \
        --name-fancy='Miniconda' \
        --name='conda' \
        "$@"
}

koopa_install_coreutils() { # {{{1
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

koopa_install_cpufetch() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/cpufetch' \
        --name='cpufetch' \
        "$@"
}

koopa_install_curl() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/curl' \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_install_doom_emacs() { # {{{1
    koopa_install_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_dotfiles() { # {{{1
    koopa_install_app \
        --name-fancy='Dotfiles' \
        --name='dotfiles' \
        --version='rolling' \
        "$@"
}

koopa_install_emacs() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/emacs' \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa_install_ensembl_perl_api() { # {{{1
    koopa_install_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        --version='rolling' \
        "$@"
}

koopa_install_findutils() { # {{{1
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
        --name='findutils' \
        "$@"
}

koopa_install_fish() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/fish' \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa_install_fzf() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/fzf' \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

# FIXME Need to add links here.
koopa_install_gawk() { # {{{1
    koopa_install_gnu_app \
        --name='gawk' \
        "$@"
}

koopa_install_gcc() { # {{{1
    koopa_install_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}

koopa_install_gdal() { # {{{1
    koopa_install_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}

koopa_install_geos() { # {{{1
    koopa_install_app \
        --name-fancy='GEOS' \
        --name='geos' \
        "$@"
}

koopa_install_git() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/git' \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa_install_gnu_app() { # {{{1
    koopa_install_app \
        --installer='gnu-app' \
        "$@"
}

# FIXME Need to add links here.
koopa_install_gnupg() { # {{{1
    koopa_install_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa_install_go() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/go' \
        --name-fancy='Go' \
        --name='go' \
        "$@"
    return 0
}

koopa_install_grep() { # {{{1
    koopa_install_gnu_app \
        --link-in-bin='bin/grep' \
        --name='grep' \
        "$@"
}

koopa_install_groff() { # {{{1
    koopa_install_gnu_app \
        --name='groff' \
        "$@"
}

koopa_install_gsl() { # {{{1
    koopa_install_gnu_app \
        --name='gsl' \
        --name-fancy='GSL' \
        "$@"
}

# FIXME Need to add link here?
koopa_install_hadolint() { # {{{1
    koopa_install_app \
        --name='hadolint' \
        "$@"
}

koopa_install_harfbuzz() { # {{{1
    koopa_install_app \
        --name-fancy='HarfBuzz' \
        --name='harfbuzz' \
        "$@"
}

# FIXME Need to add link here?
koopa_install_haskell_stack() { # {{{1
    koopa_install_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        --version='rolling' \
        "$@"
}

koopa_install_hdf5() { # {{{1
    koopa_install_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa_install_homebrew() { # {{{1
    koopa_install_app \
        --link-in-bin='Homebrew/bin/brew' \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}

koopa_install_homebrew_bundle() { # {{{1
    koopa_install_app \
        --name-fancy='Homebrew bundle' \
        --name='homebrew-bundle' \
        --system \
        "$@"
}

koopa_install_htop() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/htop' \
        --name='htop' \
        "$@"
}

koopa_install_icu4c() { # {{{1
    koopa_install_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

koopa_install_imagemagick() { # {{{1
    koopa_install_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_install_julia() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

# FIXME Specify which packages to link.
koopa_install_julia_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_install_lesspipe() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/lesspipe.sh' \
        --name='lesspipe' \
        "$@"
}

koopa_install_libevent() { # {{{1
    koopa_install_app \
        --name='libevent' \
        "$@"
}

koopa_install_libtool() { # {{{1
    koopa_install_gnu_app \
        --name='libtool' \
        "$@"
}

# FIXME Need to add link here?
koopa_install_lua() { # {{{1
    koopa_install_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

# FIXME Need to add link here?
koopa_install_luarocks() { # {{{1
    koopa_install_app \
        --name='luarocks' \
        "$@"
}

koopa_install_make() { # {{{1
    koopa_install_gnu_app \
        --link-in-bin='bin/make' \
        --name='make' \
        "$@"
}

koopa_install_mamba() { # {{{1
    koopa_install_app \
        --name-fancy='Mamba' \
        --name='mamba' \
        --system \
        "$@"
}

koopa_install_man_db() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/man' \
        --name='man-db' \
        "$@"
}

koopa_install_meson() { # {{{1
    koopa_install_app \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}

koopa_install_miniconda() { # {{{1
    koopa_install_conda "$@"
}

koopa_install_ncurses() { # {{{1
    koopa_install_gnu_app \
        --name='ncurses' \
        "$@"
}

koopa_install_neofetch() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/neofetch' \
        --name='neofetch' \
        "$@"
}

koopa_install_neovim() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/nvim' \
        --name='neovim' \
        "$@"
}

# FIXME Rework this: --link-in-make-include='bin' \
koopa_install_nim() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/nvim' \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

# FIXME Specify which packages to link.
koopa_install_nim_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_install_ninja() { # {{{1
    koopa_install_app \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}

koopa_install_node() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/node' \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

# FIXME Specify other packages to link.
koopa_install_node_packages() { # {{{1
    koopa_install_app_packages \
        --link-in-bin='bin/npm' \
        --name-fancy='Node' \
        --name='node' \
        "$@"
}

# FIXME Need to add link here?
koopa_install_openjdk() { # {{{1
    koopa_install_app \
        --name-fancy='OpenJDK' \
        --name='openjdk' \
        "$@"
}

koopa_install_openssh() { # {{{1
    koopa_install_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}

koopa_install_openssl() { # {{{1
    koopa_install_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}

koopa_install_parallel() { # {{{1
    koopa_install_gnu_app \
        --link-in-bin='bin/parallel' \
        --name='parallel' \
        "$@"
}

koopa_install_password_store() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/pass' \
        --name='password-store' \
        "$@"
}

koopa_install_patch() { # {{{1
    koopa_install_gnu_app \
        --name='patch' \
        "$@"
}

koopa_install_pcre2() { # {{{1
    koopa_install_app \
        --name-fancy='PCRE2' \
        --name='pcre2' \
        "$@"
}

koopa_install_perl() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/perl' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_install_perl_packages() { # {{{1
    koopa_install_app_packages \
        --link-in-bin='bin/cpanm' \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_install_perlbrew() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/perlbrew' \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        --version='rolling' \
        "$@"
}

koopa_install_pkg_config() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/pkg-config' \
        --name='pkg-config' \
        "$@"
}

koopa_install_prelude_emacs() { # {{{1
    koopa_install_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_proj() { # {{{1
    koopa_install_app \
        --name-fancy='PROJ' \
        --name='proj' \
        "$@"
}

koopa_install_pyenv() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/pyenv' \
        --name='pyenv' \
        --version='rolling' \
        "$@"
}

# FIXME Consider moving the linker into the main Python installer script,
# so we can detect the version...
koopa_install_python() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/python3' \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

# FIXME Need to include links here.
koopa_install_python_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_install_r() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/R' \
        --link-in-bin='bin/Rscript' \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_install_r_cmd_check() { # {{{1
    koopa_install_app \
        --name-fancy='R CMD check' \
        --name='r-cmd-check' \
        --version='rolling' \
        "$@"
}

koopa_install_r_koopa() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_r_koopa 'header'
    return 0
}

koopa_install_r_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_install_rbenv() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/rbenv' \
        --name='rbenv' \
        --version='rolling' \
        "$@"
}

koopa_install_rmate() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/rmate' \
        --name='rmate' \
        "$@"
}

koopa_install_rsync() { # {{{1
    koopa_install_app \
        --link-in-bin='rsync' \
        --name='rsync' \
        "$@"
}

koopa_install_ruby() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/ruby' \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

# FIXME Need to include links here.
koopa_install_ruby_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_install_rust() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/rustc' \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}

# FIXME Need to include links here.
koopa_install_rust_packages() { # {{{1
    koopa_install_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_install_sed() { # {{{1
    koopa_install_gnu_app \
        --link-in-bin='bin/sed' \
        --name='sed' \
        "$@"
}

koopa_install_shellcheck() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/shellcheck' \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

# FIXME Need to include link here?
koopa_install_shunit2() { # {{{1
    koopa_install_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

# FIXME Need to include link here?
koopa_install_singularity() { # {{{1
    koopa_install_app \
        --name='singularity' \
        "$@"
}

koopa_install_spacemacs() { # {{{1
    koopa_install_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_spacevim() { # {{{1
    koopa_install_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        --version='rolling' \
        "$@"
}

koopa_install_sqlite() { # {{{1
    koopa_install_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa_install_stow() { # {{{1
    # """
    # Install script uses 'Test::Output' Perl package.
    # """
    koopa_install_gnu_app \
        --activate-opt='perl' \
        --link-in-bin='bin/stow' \
        --name='stow' \
        "$@"
}

koopa_install_subversion() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/svn' \
        --name='subversion' \
        "$@"
}

# FIXME Rework this as a Python virtualenv.
koopa_install_taglib() { # {{{1
    koopa_install_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa_install_tar() { # {{{1
    koopa_install_gnu_app \
        --link-in-bin='bin/tar' \
        --name='tar' \
        "$@"
}

koopa_install_tex_packages() { # {{{1
    koopa_install_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        --version='rolling' \
        "$@"
}

# FIXME Need to include a link here?
koopa_install_texinfo() { # {{{1
    koopa_install_gnu_app \
        --name='texinfo' \
        "$@"
}

koopa_install_the_silver_searcher() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/ag' \
        --name='the-silver-searcher' \
        "$@"
}

koopa_install_tmux() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/tmux' \
        --name='tmux' \
        "$@"
}

koopa_install_udunits() { # {{{1
    koopa_install_app \
        --name='udunits' \
        "$@"
}

koopa_install_vim() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/vim' \
        --link-in-bin='bin/vimdiff' \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa_install_wget() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/wget' \
        --name='wget' \
        "$@"
}

koopa_install_zsh() { # {{{1
    koopa_install_app \
        --link-in-bin='bin/zsh' \
        --name-fancy='Zsh' \
        --name='zsh' \
        "$@"
    koopa_fix_zsh_permissions
    return 0
}

koopa_uninstall_anaconda() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Anaconda' \
        --name='anaconda' \
        "$@"
}

koopa_uninstall_armadillo() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Armadillo' \
        --name='armadillo' \
        "$@"
}

koopa_uninstall_autoconf() { # {{{1
    koopa_uninstall_app \
        --name='autoconf' \
        "$@"
}

koopa_uninstall_automake() { # {{{1
    koopa_uninstall_app \
        --name='automake' \
        "$@"
}

# FIXME Need to test this.
koopa_uninstall_bash() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Bash' \
        --name='bash' \
        --unlink-app-in-bin='bash' \
        "$@"
}

koopa_uninstall_binutils() { # {{{1
    koopa_uninstall_app \
        --name='binutils' \
        "$@"
}

koopa_uninstall_boost() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Boost' \
        --name='boost' \
        "$@"
}

koopa_uninstall_chemacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Chemacs' \
        --name='chemacs' \
        "$@"
}

koopa_uninstall_cmake() { # {{{1
    koopa_uninstall_app \
        --name-fancy='CMake' \
        --name='cmake' \
        "$@"
    return 0
}

koopa_uninstall_conda() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Miniconda' \
        --name='conda' \
        "$@"
}

koopa_uninstall_coreutils() { # {{{1
    koopa_uninstall_app \
        --name='coreutils' \
        "$@"
}

koopa_uninstall_cpufetch() { # {{{1
    koopa_uninstall_app \
        --name='cpufetch' \
        "$@"
}

koopa_uninstall_curl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='cURL' \
        --name='curl' \
        "$@"
}

koopa_uninstall_doom_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        "$@"
}

koopa_uninstall_dotfiles() { # {{{1
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

koopa_uninstall_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Emacs' \
        --name='emacs' \
        "$@"
}

koopa_uninstall_ensembl_perl_api() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ensembl Perl API' \
        --name='ensembl-perl-api' \
        "$@"
}

koopa_uninstall_findutils() { # {{{1
    koopa_uninstall_app \
        --name='findutils' \
        "$@"
}

koopa_uninstall_fish() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Fish' \
        --name='fish' \
        "$@"
}

koopa_uninstall_fzf() { # {{{1
    koopa_uninstall_app \
        --name-fancy='FZF' \
        --name='fzf' \
        "$@"
}

koopa_uninstall_gawk() { # {{{1
    koopa_uninstall_app \
        --name='gawk' \
        "$@"
}

koopa_uninstall_gcc() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GCC' \
        --name='gcc' \
        "$@"
}

koopa_uninstall_gdal() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GDAL' \
        --name='gdal' \
        "$@"
}

koopa_uninstall_geos() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GEOS' \
        --name='geos' \
        "$@"
}

koopa_uninstall_git() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Git' \
        --name='git' \
        "$@"
}

koopa_uninstall_gnupg() { # {{{1
    koopa_uninstall_app \
        --name-fancy='GnuPG suite' \
        --name='gnupg' \
        "$@"
}

koopa_uninstall_go() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Go' \
        --name='go' \
        "$@"
}

koopa_uninstall_go_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Go packages' \
        --name='go-packages' \
        "$@"
}

koopa_uninstall_grep() { # {{{1
    koopa_uninstall_app \
        --name='grep' \
        "$@"
}

koopa_uninstall_groff() { # {{{1
    koopa_uninstall_app \
        --name='groff' \
        "$@"
}

koopa_uninstall_gsl() { # {{{1
    koopa_uninstall_app \
        --name='gsl' \
        "$@"
}

koopa_uninstall_hadolint() { # {{{1
    koopa_uninstall_app \
        --name='hadolint' \
        "$@"
}

koopa_uninstall_harfbuzz() { # {{{1
    koopa_uninstall_app \
        --name-fancy='HarfBuzz' \
        --name='harfbuzz' \
        "$@"
}

koopa_uninstall_haskell_stack() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Haskell Stack' \
        --name='haskell-stack' \
        "$@"
}

koopa_uninstall_hdf5() { # {{{1
    koopa_uninstall_app \
        --name-fancy='HDF5' \
        --name='hdf5' \
        "$@"
}

koopa_uninstall_homebrew() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --system \
        "$@"
}

koopa_uninstall_htop() { # {{{1
    koopa_uninstall_app \
        --name='htop' \
        "$@"
}

koopa_uninstall_icu4c() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ICU4C' \
        --name='icu4c' \
        "$@"
}

koopa_uninstall_imagemagick() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ImageMagick' \
        --name='imagemagick' \
        "$@"
}

koopa_uninstall_julia() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Julia' \
        --name='julia' \
        "$@"
}

koopa_uninstall_julia_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Julia packages' \
        --name='julia-packages' \
        "$@"
}

koopa_uninstall_koopa() { # {{{1
    local app
    declare -A app=(
        [bash]="$(koopa_locate_bash)"
    )
    "${app[bash]}" "$(koopa_koopa_prefix)/uninstall" "$@"
    return 0
}

koopa_uninstall_lesspipe() { # {{{1
    koopa_uninstall_app \
        --name='lesspipe' \
        "$@"
}

koopa_uninstall_libevent() { # {{{1
    koopa_uninstall_app \
        --name='libevent' \
        "$@"
}

koopa_uninstall_libtool() { # {{{1
    koopa_uninstall_app \
        --name='libtool' \
        "$@"
}

koopa_uninstall_lua() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Lua' \
        --name='lua' \
        "$@"
}

koopa_uninstall_luarocks() { # {{{1
    koopa_uninstall_app \
        --name='luarocks' \
        "$@"
}

koopa_uninstall_make() { # {{{1
    koopa_uninstall_app \
        --name='make' \
        "$@"
}

koopa_uninstall_man_db() { # {{{1
    koopa_uninstall_app \
        --name='man-db' \
        "$@"
}

koopa_uninstall_meson() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Meson' \
        --name='meson' \
        "$@"
}

koopa_uninstall_miniconda() { # {{{1
    koopa_uninstall_conda "$@"
}

koopa_uninstall_ncurses() { # {{{1
    koopa_uninstall_app \
        --name='ncurses' \
        "$@"
}

koopa_uninstall_neofetch() { # {{{1
    koopa_uninstall_app \
        --name='neofetch' \
        "$@"
}

koopa_uninstall_neovim() { # {{{1
    koopa_uninstall_app \
        --name='neovim' \
        "$@"
}

koopa_uninstall_nim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Nim' \
        --name='nim' \
        "$@"
}

koopa_uninstall_nim_packages() { # {{{1
    koopa_uninstall_app \
        --name='nim-packages' \
        --name-fancy='Nim packages' \
        "$@"
}

koopa_uninstall_ninja() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ninja' \
        --name='ninja' \
        "$@"
}

koopa_uninstall_node() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Node.js' \
        --name='node' \
        "$@"
}

koopa_uninstall_node_packages() { # {{{1
    koopa_uninstall_app \
        --name='node-packages' \
        --name-fancy='Node.js packages' \
        "$@"
}

koopa_uninstall_openjdk() { # {{{1
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

koopa_uninstall_openssh() { # {{{1
    koopa_uninstall_app \
        --name-fancy='OpenSSH' \
        --name='openssh' \
        "$@"
}

koopa_uninstall_openssl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='OpenSSL' \
        --name='openssl' \
        "$@"
}

koopa_uninstall_parallel() { # {{{1
    koopa_uninstall_app \
        --name='parallel' \
        "$@"
}

koopa_uninstall_password_store() { # {{{1
    koopa_uninstall_app \
        --name='password-store' \
        "$@"
}

koopa_uninstall_patch() { # {{{1
    koopa_uninstall_app \
        --name='patch' \
        "$@"
}

koopa_uninstall_pcre2() { # {{{1
    koopa_uninstall_app \
        --name-fancy='PCRE2' \
        --name='pcre2' \
        "$@"
}

koopa_uninstall_perl() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perl' \
        --name='perl' \
        "$@"
}

koopa_uninstall_perl_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perl packages' \
        --name='perl-packages' \
        "$@"
    koopa_rm "${HOME:?}/.cpan" "${HOME:?}/.cpanm"
    return 0
}

koopa_uninstall_perlbrew() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Perlbrew' \
        --name='perlbrew' \
        "$@"
}

koopa_uninstall_pkg_config() { # {{{1
    koopa_uninstall_app \
        --name='pkg-config' \
        "$@"
}

koopa_uninstall_prelude_emacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        "$@"
}

koopa_uninstall_proj() { # {{{1
    koopa_uninstall_app \
        --name-fancy='PROJ' \
        --name='proj' \
        "$@"
}

koopa_uninstall_pyenv() { # {{{1
    koopa_uninstall_app \
        --name='pyenv' \
        "$@"
}

koopa_uninstall_python() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        "$@"
}

koopa_uninstall_python_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Python packages' \
        --name='python-packages' \
        "$@"
}

koopa_uninstall_python_virtualenvs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Python virtualenvs' \
        --name='python-virtualenvs' \
        "$@"
}

koopa_uninstall_r() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R' \
        --name='r' \
        "$@"
}

koopa_uninstall_r_cmd_check() { # {{{1
    koopa_uninstall_app \
        --name='r-cmd-check' \
        "$@"
}

koopa_uninstall_r_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

koopa_uninstall_rbenv() { # {{{1
    koopa_uninstall_app \
        --name='rbenv' \
        "$@"
}

koopa_uninstall_rmate() { # {{{1
    koopa_uninstall_app \
        --name='rmate' \
        "$@"
}

koopa_uninstall_rsync() { # {{{1
    koopa_uninstall_app \
        --name='rsync' \
        "$@"
}

koopa_uninstall_ruby() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ruby' \
        --name='ruby' \
        "$@"
}

koopa_uninstall_ruby_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Ruby packages' \
        --name='ruby-packages' \
        "$@"
}

koopa_uninstall_rust() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_uninstall_rust_packages() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa_uninstall_sed() { # {{{1
    koopa_uninstall_app \
        --name='sed' \
        "$@"
}

koopa_uninstall_shellcheck() { # {{{1
    koopa_uninstall_app \
        --name-fancy='ShellCheck' \
        --name='shellcheck' \
        "$@"
}

koopa_uninstall_shunit2() { # {{{1
    koopa_uninstall_app \
        --name-fancy='shUnit2' \
        --name='shunit2' \
        "$@"
}

koopa_uninstall_singularity() { # {{{1
    koopa_uninstall_app \
        --name='singularity' \
        "$@"
}

koopa_uninstall_spacemacs() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        "$@"
}

koopa_uninstall_spacevim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        "$@"
}

koopa_uninstall_sqlite() { # {{{1
    koopa_uninstall_app \
        --name-fancy='SQLite' \
        --name='sqlite' \
        "$@"
}

koopa_uninstall_stow() { # {{{1
    koopa_uninstall_app \
        --name='stow' \
        "$@"
}

koopa_uninstall_subversion() { # {{{1
    koopa_uninstall_app \
        --name='subversion' \
        "$@"
}

koopa_uninstall_taglib() { # {{{1
    koopa_uninstall_app \
        --name-fancy='TagLib' \
        --name='taglib' \
        "$@"
}

koopa_uninstall_tar() { # {{{1
    koopa_uninstall_app \
        --name='tar' \
        "$@"
}

koopa_uninstall_texinfo() { # {{{1
    koopa_uninstall_app \
        --name='texinfo' \
        "$@"
}

koopa_uninstall_the_silver_searcher() { # {{{1
    koopa_uninstall_app \
        --name='the-silver-searcher' \
        "$@"
}

koopa_uninstall_tmux() { # {{{1
    koopa_uninstall_app \
        --name='tmux' \
        "$@"
}

koopa_uninstall_udunits() { # {{{1
    koopa_uninstall_app \
        --name='udunits' \
        "$@"
}

koopa_uninstall_vim() { # {{{1
    koopa_uninstall_app \
        --name-fancy='Vim' \
        --name='vim' \
        "$@"
}

koopa_uninstall_wget() { # {{{1
    koopa_uninstall_app \
        --name='wget' \
        "$@"
}

koopa_uninstall_zsh() { # {{{1
    koopa_uninstall_app \
        --name-fancy="Zsh" \
        --name='zsh' \
        "$@"
}

koopa_update_chemacs() { # {{{1
    koopa_update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa_update_doom_emacs() { # {{{1
    koopa_update_app \
        --name-fancy='Doom Emacs' \
        --name='doom-emacs' \
        --prefix="$(koopa_doom_emacs_prefix)" \
        "$@"
}

koopa_update_dotfiles() { # {{{1
    koopa_update_app \
        --name='dotfiles' \
        --name-fancy='Dotfiles' \
        "$@"
}

koopa_update_google_cloud_sdk() { # {{{1
    koopa_update_app \
        --name-fancy='Google Cloud SDK' \
        --name='google-cloud-sdk' \
        --system \
        "$@"
}

koopa_update_homebrew() { # {{{1
    koopa_update_app \
        --name-fancy='Homebrew' \
        --name='homebrew' \
        --prefix="$(koopa_homebrew_prefix)" \
        --system \
        "$@"
}

koopa_update_julia_packages() { # {{{1
    koopa_install_julia_packages "$@"
}

koopa_update_koopa() { # {{{1
    koopa_update_app \
        --name='koopa' \
        --prefix="$(koopa_koopa_prefix)" \
        --system \
        "$@"
}

koopa_update_mamba() { # {{{1
    koopa_install_mamba "$@"
}

koopa_update_nim_packages() { # {{{1
    koopa_install_nim_packages "$@"
}

koopa_update_node_packages() { # {{{1
    koopa_install_node_packages "$@"
}

koopa_update_perl_packages() { # {{{1
    koopa_install_perl_packages "$@"
}

koopa_update_perlbrew() { # {{{1
    koopa_update_app \
        --name='perlbrew' \
        --name-fancy='Perlbrew' \
        "$@"
}

koopa_update_prelude_emacs() { # {{{1
    koopa_update_app \
        --name-fancy='Prelude Emacs' \
        --name='prelude-emacs' \
        --prefix="$(koopa_prelude_emacs_prefix)" \
        "$@"
}

koopa_update_pyenv() { # {{{1
    koopa_update_app \
        --name='pyenv' \
        "$@"
}

koopa_update_r_cmd_check() { # {{{1
    koopa_update_app \
        --name='r-cmd-check' \
        --name-fancy='R CMD check' \
        "$@"
}

koopa_update_r_packages() { # {{{1
    koopa_update_app \
        --name-fancy='R packages' \
        --name='r-packages' \
        "$@"
}

koopa_update_rbenv() { # {{{1
    koopa_update_app \
        --name='rbenv' \
        "$@"
}

koopa_update_ruby_packages() {  # {{{1
    koopa_install_ruby_packages "$@"
}

koopa_update_rust() { # {{{1
    koopa_update_app \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa_update_rust_packages() { # {{{1
    koopa_update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa_update_spacemacs() { # {{{1
    koopa_update_app \
        --name-fancy='Spacemacs' \
        --name='spacemacs' \
        --prefix="$(koopa_spacemacs_prefix)" \
        "$@"
}

koopa_update_spacevim() { # {{{1
    koopa_update_app \
        --name-fancy='SpaceVim' \
        --name='spacevim' \
        --prefix="$(koopa_spacevim_prefix)" \
        "$@"
}

koopa_update_system() { # {{{1
    koopa_update_app \
        --name='system' \
        --system \
        "$@"
}

koopa_update_tex_packages() { # {{{1
    koopa_update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
