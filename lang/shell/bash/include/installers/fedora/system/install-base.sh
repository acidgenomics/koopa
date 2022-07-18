#!/usr/bin/env bash

main() {
    # """
    # Install Fedora base system.
    # @note Updated 2022-07-18.
    #
    # Use '<pkg>-<version>' to pin package versions.
    #
    # Refer to Debian install base script for more details on supported args.
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=(
        # > 'coreutils'
        # > 'emacs'
        # > 'gdal-devel'
        # > 'geos-devel'
        # > 'golang'
        # > 'llvm'
        # > 'llvm-devel'
        # > 'nim'
        # > 'proj-devel'
        'R'
        'apr-devel' # subversion
        'apr-util-devel' # subversion
        'autoconf'
        'automake'
        'bash'
        'bc'
        'bison-devel'
        'byacc'
        'bzip2'
        'bzip2-devel'
        'cairo-devel' # harfbuzz
        'chkconfig'
        'cmake'
        'convmv'
        'cryptsetup'
        'curl'
        'curl'
        'diffutils'
        'expat-devel' # udunits
        'expect' # Installs unbuffer.
        'file'
        'findutils'
        'flex-devel'
        'fontconfig-devel'
        'freetype-devel' # freetype, harfbuzz, ragg
        'fribidi-devel' # textshaping
        'gcc'
        'gcc-c++'
        'gcc-gfortran'
        'gettext'
        'git'
        'glib2-devel' # ag, harfbuzz
        'glibc-langpack-en'
        'glibc-locale-source'
        'gmp-devel'
        'gnupg2'
        'gnutls'
        'gnutls-devel'
        'gsl-devel'
        'gtk-doc' # harfbuzz
        'harfbuzz-devel' # textshaping
        'hdf5-devel'
        'jq'
        'less'
        'libcurl-devel'
        'libevent-devel' # tmux
        'libffi-devel'
        'libgit2-devel'
        'libicu-devel' # rJava
        'libjpeg-turbo-devel' # freetype / ragg
        'libmpc-devel'
        'libpng-devel' # freetype / ragg
        'libseccomp-devel'
        'libssh2-devel'
        'libtiff-devel'
        'libtool'
        'libuuid-devel'
        'libxcrypt-compat'
        'libxml2-devel'
        'libzstd-devel' # rsync
        'lua'
        'lz4-devel' # rsync
        'make'
        'man-db'
        'mariadb-devel'
        'meson' # harfbuzz
        'mpfr-devel'
        'ncurses-devel'
        'ncurses-devel' # zsh
        'openblas-devel'
        'openjpeg2-devel' # GDAL
        'openssl'
        'openssl-devel'
        'patch' # bash
        'pcre-devel' # ag
        'pcre2-devel' # rJava
        'pkgconfig' # This is now 'pkgconf' wrapped.
        'postgresql-devel'
        'procps' # ps
        'python3-devel'
        'qpdf'
        'readline'
        'readline-devel' # R
        'ruby'
        'sqlite-devel'
        'squashfs-tools'
        'sudo'
        'systemd'
        'taglib-devel'
        'tar'
        'texinfo'
        'texlive'
        'texlive-bera'
        'texlive-caption'
        'texlive-changepage'
        'texlive-collection-fontsrecommended'
        'texlive-collection-latexrecommended'
        'texlive-enumitem'
        'texlive-etoolbox'
        'texlive-fancyhdr'
        'texlive-footmisc'
        'texlive-framed'
        'texlive-geometry'
        'texlive-hyperref'
        'texlive-latex-fonts'
        'texlive-natbib'
        'texlive-parskip'
        'texlive-pdftex'
        'texlive-placeins'
        'texlive-preprint'
        'texlive-sectsty'
        'texlive-soul'
        'texlive-titlesec'
        'texlive-titling'
        'texlive-xstring'
        'tmux'
        'tree'
        'udunits2-devel'
        'unixODBC-devel'
        'unzip'
        'util-linux'
        'vim'
        'wget'
        'which'
        'xmlto'
        'xxhash-devel' # rsync
        'xz'
        'xz-devel'
        'yum-utils'
        'zip'
        'zlib-devel'
        'zsh'
    )
    koopa_fedora_dnf update
    koopa_fedora_dnf groupinstall 'Development Tools'
    koopa_fedora_dnf_install "${pkgs[@]}"
    koopa_fedora_dnf clean all
    koopa_fedora_set_locale
    return 0
}
