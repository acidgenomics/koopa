#!/usr/bin/env bash

# FIXME All conservative apps should be built before the liberal ones.
# FIXME Improve labeling of dependencies here and in app.json.
# FIXME Rework this install recipe as an algorithm that uses app.json.

koopa_build_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2022-09-02.
    #
    # The approach calling 'koopa_cli_install' internally on apps array
    # can run into weird compilation issues on macOS.
    # """
    local app_name apps koopa push_apps
    koopa_assert_has_no_args "$#"
    [[ -n "${KOOPA_AWS_CLOUDFRONT_DISTRIBUTION_ID:-}" ]] || return 1
    koopa="$(koopa_locate_koopa)"
    [[ -x "$koopa" ]] || return 1
    apps=()
    apps+=(
        # deps: make (system).
        'pkg-config'
        # deps: make (system).
        'make'
    )
    koopa_is_linux && apps+=(
        # deps: make, pkg-config.
        'attr'
    )
    apps+=(
        # deps: attr (linux), make.
        'patch'
        # deps: make, pkg-config.
        'xz'
        # deps: make.
        'm4'
        # deps: m4, make, pkg-config.
        'gmp'
        # deps: make.
        'gperf'
        # deps: gmp, make, pkg-config.
        'mpfr'
        # deps: gmp, make, mpfr.
        'mpc'
        # deps: gmp, make, mpc, mpfr.
        'gcc'
        # deps: m4, make.
        'autoconf'
        # deps: autoconf, make.
        'automake'
        # deps: m4, make.
        'libtool'
        # deps: m4, make.
        'bison'
        # deps: make, patch, pkg-config.
        'bash'
        # deps: attr (linux), gmp, gperf, make.
        'coreutils'
        # deps: make.
        'findutils'
        # deps: make.
        'sed'
        # deps: make, pkg-config.
        'ncurses'
        # deps: make, pkg-config.
        'icu4c'
        # deps: make, ncurses, pkg-config.
        'readline'
        # deps: icu4c, make, pkg-config, readline.
        'libxml2'
        # deps: libxml2 (linux), make, ncurses (linux), pkg-config.
        'gettext'
        # deps: make, pkg-config.
        'zlib'
        # deps: none.
        'ca-certificates'
        # deps: ca-certificates, make, pkg-config.
        'openssl1'
        # deps: ca-certificates, make, pkg-config.
        'openssl3'
        # deps: make, ncurses, openssl3.
        'cmake'
        # deps: cmake.
        'zstd'
        # deps: ca-certificates, make, openssl3, pkg-config, zlib, zstd.
        'curl'
        # deps: autoconf, curl, gettext, make, openssl3, zlib.
        'git'
        # deps: cmake, gcc, pkg-config.
        'lapack'
        # deps: make, pkg-config.
        'libffi'
        # deps: cmake, make, pkg-config.
        'libjpeg-turbo'
        # deps: make, pkg-config, zlib.
        'libpng'
        # deps: libjpeg-turbo, make, pkg-config, zstd.
        'libtiff'
        # deps: gcc, make, pkg-config.
        'openblas'
        # deps: make.
        'bzip2'
        # deps: autoconf, automake, bzip2, libtool, make, pkg-config, zlib.
        'pcre'
        # deps: autoconf, automake, bzip2, libtool, make, pkg-config, zlib.
        'pcre2'
        # deps: make, pkg-config.
        'expat'
        # deps: make, readline.
        'gdbm'
        # deps: make, pkg-config, readline, zlib.
        'sqlite'
        # deps: bzip2, expat, gdbm, libffi, make, ncurses, openssl3, pkg-config,
        # readline, sqlite, xz, zlib.
        'python'
        'xorg-xorgproto'
        'xorg-xcb-proto'
        'xorg-libpthread-stubs'
        'xorg-xtrans'
        'xorg-libice'
        'xorg-libsm'
        'xorg-libxau'
        'xorg-libxdmcp'
        'xorg-libxcb'
        'xorg-libx11'
        'xorg-libxext'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-libxrandr'
        'tcl-tk'
        'perl'
        'texinfo'
        'meson'
        'ninja'
        'glib'
        'freetype'
        'fontconfig'
        'lzo'
        'pixman'
        'cairo'
        'hdf5'
        'openjdk'
        'libssh2'
        'libgit2'
        'jpeg'
        'nettle'
        'libzip'
        'imagemagick'
        'graphviz'
        'geos'
        'proj'
        'gdal'
        'fribidi'
        'harfbuzz'
        'gawk'
        'libuv'
        'conda'
        'udunits'
        'r'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
        'flex'
        'binutils'
        'cpufetch'
        'exiftool'
        'libtasn1'
        'libunistring'
        'texinfo'
        'gnutls'
        'emacs'
        'vim'
        'lua'
        'luarocks'
        'neovim'
        # NOTE Consider moving these up in the install order.
        'libevent'
        'utf8proc'
        # deps: libevent, utf8proc.
        'tmux'
        'htop'
        'boost'
        'fish'
        'zsh'
        'lame'
        'ffmpeg'
        'flac'
        'fltk'
        'libgpg-error'
        'libgcrypt'
        'libassuan'
        'libksba'
        'npth'
    )
    koopa_is_linux && apps+=('pinentry')
    apps+=(
        'gnupg'
        'grep'
        'groff'
        'gsl'
        'gzip'
        'oniguruma'
        'jq'
        'less'
        'lesspipe'
        'libidn'
        'libpipeline'
        'lz4'
        'man-db'
        'neofetch'
        'nim'
        'parallel'
        'password-store'
        'taglib'
        'pytaglib'
        'pytest'
        'xxhash'
        'rsync'
        'scons'
        'serf' # deps: scons.
        'ruby' # deps: openssl3, zlib.
        'subversion' # deps: ruby, serf.
        'r-devel' # deps: subversion.
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tar'
        'tree'
        'units'
        'wget'
        'which'
        'libgeotiff'
        # FIXME Need to finish out recipe here.
        # Install Go packages.
        'go'
        'chezmoi' # deps: go
        'fzf' # deps: go
        # Install Cloud SDKs.
        'aws-cli'
        'azure-cli'
        'google-cloud-sdk'
        # deps: python.
        'autoflake'
        # deps: python.
        'black'
        # deps: python.
        'bpytop'
        # deps: python.
        'flake8'
        # deps: python.
        'glances'
        # deps: python.
        'ipython'
        # deps: python.
        'isort'
        # deps: python.
        'latch'
        # deps: python.
        'pipx'
        # deps: python.
        'poetry'
        # deps: python.
        'pycodestyle'
        # deps: python.
        'pyflakes'
        # deps: python.
        'pygments'
        # deps: python.
        'pylint'
        # deps: python.
        'ranger-fm'
        # deps: python.
        'ruff'
        # deps: python.
        'yt-dlp'
        'libedit'
        # deps: libedit.
        'openssh'
        'c-ares'
        'jemalloc'
        'libev'
        # deps: jemalloc, libev.
        'nghttp2'
        # deps: c-ares, nghttp2.
        'node'
        'rust'
        'julia'
        # deps: rust.
        'bat'
        # deps: rust.
        'broot'
        # deps: rust.
        'delta'
        # deps: rust.
        'difftastic'
        # deps: rust.
        'dog'
        # deps: rust.
        'du-dust'
        # deps: rust.
        'exa'
        # deps: rust.
        'fd-find'
        # deps: rust.
        'hyperfine'
        # deps: rust.
        'mcfly'
        # deps: rust.
        'mdcat'
        # deps: rust.
        'procs'
        # deps: rust.
        'ripgrep'
        # deps: rust.
        'ripgrep-all'
        # deps: rust.
        'starship'
        # deps: rust.
        'tealdeer'
        # deps: rust.
        'tokei'
        # deps: rust.
        'tuc'
        # deps: rust.
        'xsv'
        # deps: rust.
        'zellij'
        # deps: rust.
        'zoxide'
        # deps: go.
        'chemacs'
        # deps: go.
        'cheat'
        # deps: go.
        'yq'
        # deps: node.
        'bash-language-server'
        # deps: node.
        'gtop'
        # deps: node.
        'prettier'
        # deps: perl.
        'ack'
        # deps: perl.
        'rename'
        # deps: ruby.
        'bashcov'
        # deps: ruby.
        'colorls'
        # deps: ruby.
        'ronn'
        # deps: none.
        'pyenv'
        # deps: none.
        'rbenv'
        # deps: none.
        'dotfiles'
        # deps: none.
        'ensembl-perl-api'
        # deps: cmake, gcc, hdf5, libxml2, python.
        'sra-tools'
        'yarn'
        'asdf'
        'convmv'
        'editorconfig'
        'markdownlint-cli'
        'nmap'
        'rmate'
        # deps: bzip2.
        'unzip'
    )
    if ! koopa_is_aarch64
    then
        apps+=(
            # deps: none.
            'anaconda'
            # deps: none.
            'haskell-stack'
            # deps: haskell-stack.
            'hadolint'
            # deps: haskell-stack.
            'pandoc'
            # deps: conda.
            'bioconda-utils'
            # deps: conda.
            'bamtools'
            # deps: conda.
            'bedtools'
            # deps: conda.
            'bioawk'
            # deps: conda.
            'bowtie2'
            # deps: conda.
            'bustools'
            # deps: conda.
            'deeptools'
            # deps: conda.
            'entrez-direct'
            # deps: conda.
            'fastqc'
            # deps: conda.
            'ffq'
            # deps: conda.
            'gffutils'
            # deps: conda.
            'gget'
            # deps: conda.
            'ghostscript'
            # deps: conda.
            'gseapy'
            # deps: conda.
            'hisat2'
            # deps: conda.
            'htseq'
            # deps: conda.
            'jupyterlab'
            # deps: conda.
            'kallisto'
            # deps: conda.
            'multiqc'
            # deps: conda.
            'nextflow'
            # deps: conda.
            'salmon'
            # deps: conda.
            'sambamba'
            # deps: conda.
            'samtools'
            # deps: conda.
            'snakefmt'
            # deps: conda.
            'snakemake'
            # deps: conda.
            'star'
            # deps: conda.
            'visidata'
        )
    fi
    if koopa_is_linux
    then
        apps+=(
            # deps: go, pkg-config.
            'apptainer'
            # deps: lua, luarocks, pkg-config, tcl-tk, zlib.
            'lmod'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                # deps: none.
                'aspera-connect'
                # deps: none.
                'docker-credential-pass'
            )
        fi
    fi
    for app_name in "${apps[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix --allow-missing "$app_name")"
        koopa_alert "$prefix"
        [[ -d "$prefix" ]] && continue
        PATH="${KOOPA_PREFIX:?}/bootstrap/bin:${PATH:-}" \
            "$koopa" install "$app_name"
        push_apps+=("$app_name")
    done
    if koopa_is_array_non_empty "${push_apps[@]:-}"
    then
        for app_name in "${push_apps[@]}"
        do
            koopa_push_app_build "$app_name" || true
        done
    fi
    return 0
}
