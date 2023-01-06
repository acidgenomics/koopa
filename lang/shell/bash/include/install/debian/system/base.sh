#!/usr/bin/env bash

main() {
    pkgs=(
        'libaprutil1-dev' # subversion
        'libatlas-base-dev' # armadillo
        'libattr1-dev' # coreutils
        'libblas-dev'
        'libboost-chrono-dev' # bcl2fastq
        'libboost-date-time-dev' # bcl2fastq
        'libboost-dev' # bcl2fastq
        'libboost-filesystem-dev' # bcl2fastq
        'libboost-iostreams-dev' # bcl2fastq
        'libboost-program-options-dev' # bcl2fastq
        'libboost-thread-dev' # bcl2fastq
        'libboost-timer-dev' # bcl2fastq
        'libbrotli-dev' # node.js
        'libc-ares-dev' # node.js
        'libcairo2-dev' # harfbuzz
        'libcap-dev' # coreutils
        'libclang-dev' # rstudio-server
        'libcurl4-openssl-dev' # or 'libcurl4-gnutls-dev'; r-devel
        'libedit-dev' # openssh
        'libevent-dev'
        'libffi-dev'
        'libfftw3-dev'
        'libfido2-dev' # openssh
        'libfontconfig1-dev'
        'libfreetype6-dev' # harfbuzz
        'libfribidi-dev'
        'libgfortran5' # R nlme
        'libgif-dev'
        'libgit2-dev'
        'libgl1-mesa-dev'
        'libglib2.0-dev' # ag, harfbuzz
        'libglu1-mesa-dev'
        'libgmp-dev'
        'libgnutls28-dev'
        'libgsl-dev'
        'libgtk-3-0'
        'libgtk-3-dev'
        'libgtk2.0-0'
        'libgtk2.0-dev'
        'libgtkmm-2.4-dev'
        'libharfbuzz-dev'
        'libhdf5-dev'
        'libjpeg-dev'
        'libjpeg-turbo8-dev'
        'libkrb5-dev' # openssh
        'liblapack-dev'
        'libldns-dev' # openssh
        'liblz4-dev' # rsync
        # > 'liblzma-dev'
        'libmagick++-dev'
        'libmodule-build-perl'
        'libmpc-dev'
        'libmpfr-dev'
        'libncurses-dev'
        'libncurses-dev' # zsh
        'libncurses5-dev' # r-devel
        'libnetcdf-dev'
        'libnghttp2-dev' # node.js
        'libopenbabel-dev'
        'libopenblas-base'
        'libopenblas-dev'
        'libopenjp2-7-dev' # GDAL
        'libopenmpi-dev'
        'libpam0g-dev' # openssh
        'libpango1.0-dev' # r-devel
        'libpcre2-dev' # rJava
        'libpcre3-dev' # ag; r-devel
        'libperl-dev'
        'libpng-dev'
        'libpoppler-cpp-dev'
        'libpq-dev'
        'libprotobuf-dev'
        'libprotoc-dev'
        'libreadline-dev'
        'libsasl2-dev'
        'libserf-dev' # subversion (for HTTPS)
        'libsodium-dev'
        'libssh2-1-dev'
        'libssl-dev'
        'libstdc++6'
        'libtag1-dev'
        'libtiff5-dev'
        'libtool'
        'libtool-bin'
        'libudunits2-dev'
        'libv8-dev'
        'libx11-dev'
        'libxml2-dev'
        'libxpm-dev'
        'libxt-dev'
        'libxxhash-dev' # rsync; not available on Ubuntu 18
        'libz-dev'
        'libzstd-dev' # rsync
        'locales'
        'lsb-release'
        'man-db'
        'meson' # harfbuzz
        'mpack' # r-devel
        'nano'
        'ninja-build' # harfbuzz
        'pandoc' # nodejs
        'parallel'
        'pkg-config'
        'procps' # ps
        'psmisc' # RStudio Server
        'python3'
        'python3-dev'
        'python3-venv'
        'rsync'
        'ruby' # Homebrew
        'software-properties-common'
        'sqlite3'
        'subversion' # r-devel
        'tcl-dev'
        'tcl8.6-dev' # r-devel
        'texinfo' # makeinfo
        'tk-dev'
        'tk8.6-dev' # r-devel
    )
