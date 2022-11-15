#!/usr/bin/env bash

koopa_install_all_binary_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2022-11-15.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local app app_name apps dict
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A dict=(
        ['blocks']="$(koopa_disk_512k_blocks '/')"
        ['large']=0
    )
    [[ "${dict['blocks']}" -ge 500000000 ]] && dict['large']=1
    apps=()
    # Priority -----------------------------------------------------------------
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'zstd'
        'bzip2'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'curl'
        'm4'
        'gmp'
        'coreutils'
        'findutils'
        'gettext'
        'libiconv'
        'pcre'
        'pcre2'
        'grep'
        'sed'
    )
    # Alphabetical -------------------------------------------------------------
    apps+=(
        # > 'libluv'
        # > 'libtermkey'
        # > 'libvterm'
        # > 'luajit'
        # > 'mamba'
        # > 'msgpack'
        # > 'tree-sitter'
        # > 'unibilium'
        'ack'
        'apr'
        'apr-util'
        'armadillo'
        'asdf'
        'aspell'
        'autoconf'
        'autoflake'
        'automake'
        'bash'
        'bash-language-server'
        'bashcov'
        'bat'
        'bc'
        'bfg'
        'binutils'
        'bison'
        'black'
        'boost'
        'bpytop'
        'broot'
        'c-ares'
        'cairo'
        'cheat'
        'chemacs'
        'chezmoi'
        'cmake'
        'colorls'
        'conda'
        'convmv'
        'cpufetch'
        'csvkit'
        'csvtk'
        'delta'
        'difftastic'
        'dog'
        'dotfiles'
        'du-dust'
        'editorconfig'
        'emacs'
        'entrez-direct'
        'exa'
        'exiftool'
        'expat'
        'fd-find'
        'ffmpeg'
        'fish'
        'flac'
        'flake8'
        'flex'
        'fltk'
        'fmt'
        'fontconfig'
        'freetype'
        'fribidi'
        'fzf'
        'gawk'
        'gcc'
        'gdal'
        'gdbm'
        'geos'
        'ghostscript'
        'git'
        'glances'
        'glib'
        'gnupg'
        'gnutls'
        'googletest'
        'gperf'
        'graphviz'
        'groff'
        'gsl'
        'gtop'
        'gum'
        'gzip'
        'hadolint'
        'harfbuzz'
        'hdf5'
        'htop'
        'httpie'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isort'
        'jemalloc'
        'jpeg'
        'jq'
        'jupyterlab'
        'lame'
        'lapack'
        'latch'
        'less'
        'lesspipe'
        'libarchive'
        'libassuan'
        'libedit'
        'libev'
        'libevent'
        'libffi'
        'libgcrypt'
        'libgeotiff'
        'libgit2'
        'libgpg-error'
        'libidn'
        'libjpeg-turbo'
        'libksba'
        'libpipeline'
        'libpng'
        'libsolv'
        'libssh2'
        'libtasn1'
        'libtiff'
        'libtool'
        'libunistring'
        'libuv'
        'libxml2'
        'libzip'
        'lsd'
        'lua'
        'luarocks'
        'lz4'
        'lzo'
        'make'
        'man-db'
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'mpc'
        'mpdecimal'
        'mpfr'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nghttp2'
        'ninja'
        'nlohmann-json'
        'nmap'
        'node'
        'npth'
        'nushell'
        'oniguruma'
        'openblas'
        'openjdk'
        'openssh'
        'pandoc'
        'parallel'
        'password-store'
        'patch'
        'perl'
        'pipx'
        'pixman'
        'pkg-config'
        'poetry'
        'prettier'
        'procs'
        'proj'
        'py-spy'
        'pybind11'
        'pycodestyle'
        'pyenv'
        'pyflakes'
        'pygments'
        'pylint'
        'pytaglib'
        'pytest'
        'python3.10'
        'python3.11'
        'r'
        'r-devel'
        'radian'
        'ranger-fm'
        'rbenv'
        'readline'
        'rename'
        'reproc'
        'ripgrep'
        'ripgrep-all'
        'rmate'
        'ronn'
        'rsync'
        'ruby'
        'ruff'
        'scons'
        'serf'
        'shellcheck'
        'shunit2'
        'sox'
        'spdlog'
        'sqlite'
        'starship'
        'stow'
        'subversion'
        'swig'
        'taglib'
        'tar'
        'tcl-tk'
        'tealdeer'
        'termcolor'
        'texinfo'
        'tl-expected'
        'tmux'
        'tokei'
        'tree'
        'tuc'
        'udunits'
        'units'
        'unzip'
        'utf8proc'
        'vim'
        'visidata'
        'vulture'
        'wget'
        'which'
        'xorg-libice'
        'xorg-libpthread-stubs'
        'xorg-libsm'
        'xorg-libx11'
        'xorg-libxau'
        'xorg-libxcb'
        'xorg-libxdmcp'
        'xorg-libxext'
        'xorg-libxrandr'
        'xorg-libxrender'
        'xorg-libxt'
        'xorg-xcb-proto'
        'xorg-xorgproto'
        'xorg-xtrans'
        'xsv'
        'xxhash'
        'xz'
        'yaml-cpp'
        'yarn'
        'yq'
        'yt-dlp'
        'zellij'
        'zip'
        'zoxide'
        'zsh'
    )
    # Platform-specific --------------------------------------------------------
    if koopa_is_linux
    then
        apps+=(
            'apptainer'
            'aspera-connect'
            'docker-credential-pass'
            'elfutils'
            'lmod'
            'pinentry'
        )
    fi
    # Large machines only ------------------------------------------------------
    # NOTE Consider defining these in app.json.
    if [[ "${dict['large']}" -eq 1 ]]
    then
        apps+=(
            'anaconda'
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'bamtools'
            'bedtools'
            'bioawk'
            'bioconda-utils'
            'bowtie2'
            'bustools'
            'deeptools'
            'ensembl-perl-api'
            'fastqc'
            'ffq'
            'gatk'
            'gffutils'
            'gget'
            'go'
            'google-cloud-sdk'
            'gseapy'
            'haskell-cabal'
            'haskell-ghcup'
            'haskell-stack'
            'hisat2'
            'htseq'
            'julia'
            'kallisto'
            'llvm'
            'multiqc'
            'nextflow'
            'nim'
            'openbb'
            'rust'
            'salmon'
            'sambamba'
            'samtools'
            'snakefmt'
            'snakemake'
            'sra-tools'
            'star'
        )
    fi
    koopa_add_to_path_start "$(koopa_bootstrap_bin_prefix)"
    PATH="${PATH:?}" "${app['koopa']}" install 'aws-cli'
    for app_name in "${apps[@]}"
    do
        PATH="${PATH:?}" "${app['koopa']}" install --binary "$app_name"
    done
    return 0
}
