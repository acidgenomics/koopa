#!/usr/bin/env bash

koopa_install_all_binary_apps() {
    # ""
    # Install all shared apps as binary packages.
    # @note Updated 2023-03-20.
    #
    # This will currently fail for platforms where not all apps can be
    # successfully compiled, such as ARM.
    #
    # Need to install PCRE libraries before grep.
    # """
    local app app_name apps bool
    koopa_assert_has_no_args "$#"
    declare -A app
    app['koopa']="$(koopa_locate_koopa)"
    [[ -x "${app['koopa']}" ]] || return 1
    declare -A bool
    bool['large']=0
    koopa_has_large_system_disk && bool['large']=1
    apps=()
    # Priority -----------------------------------------------------------------
    koopa_is_linux && apps+=('attr')
    apps+=(
        'zlib'
        'lz4'
        'zstd'
        'bzip2'
        'ca-certificates'
        'openssl1'
        'openssl3'
        'curl'
        'curl7'
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
        'bottom'
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
        'diff-so-fancy'
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
        'fontconfig'
        'freetype'
        'fribidi'
        'fzf'
        'gawk'
        'gcc'
        'gdal'
        'gdbm'
        'geos'
        'gh'
        'git'
        'git-lfs'
        'glances'
        'glib'
        'gnupg'
        'gnutls'
        'go'
        'gperf'
        'graphviz'
        'grex'
        'groff'
        'gsl'
        'gtop'
        'gum'
        'gzip'
        'harfbuzz'
        'hdf5'
        'hexyl'
        'htop'
        'httpie'
        'hugo'
        'hyperfine'
        'icu4c'
        'imagemagick'
        'ipython'
        'isl'
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
        'libssh2'
        'libtasn1'
        'libtiff'
        'libtool'
        'libunistring'
        'libuv'
        'libxml2'
        'libyaml'
        'libzip'
        'llama'
        'lsd'
        'lua'
        'luarocks'
        'lzo'
        'make'
        'man-db'
        'markdownlint-cli'
        'mcfly'
        'mdcat'
        'meson'
        'miller'
        'mpc'
        'mpdecimal'
        'mpfr'
        'nano'
        'ncurses'
        'neofetch'
        'neovim'
        'nettle'
        'nghttp2'
        'ninja'
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
        'radian'
        'ranger-fm'
        'rbenv'
        'readline'
        'rename'
        'ripgrep'
        'ripgrep-all'
        'rmate'
        'ronn'
        'rsync'
        'ruby'
        'ruff'
        'scons'
        'sd'
        'serf'
        'shellcheck'
        'shunit2'
        'sox'
        'sqlite'
        'starship'
        'stow'
        'subversion'
        'swig'
        'taglib'
        'tar'
        'tcl-tk'
        'tealdeer'
        'texinfo'
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
        'yapf'
        'yarn'
        'yq'
        'yt-dlp'
        'zellij'
        'zip'
        'zoxide'
        'zsh'
    )
    # Architecture-specific ----------------------------------------------------
    if ! koopa_is_aarch64
    then
        apps+=(
            'hadolint'
            'pandoc'
        )
    fi
    # Platform-specific --------------------------------------------------------
    if koopa_is_linux
    then
        apps+=(
            'docker-credential-pass'
            'elfutils'
            'pinentry'
        )
    # > elif koopa_is_macos
    # > then
    # >     apps+=('trash')
    fi
    # Large machines only ------------------------------------------------------
    if [[ "${bool['large']}" -eq 1 ]]
    then
        apps+=(
            'apache-airflow'
            'apache-spark'
            'azure-cli'
            'cli11'
            'ensembl-perl-api'
            'fmt'
            'ghostscript'
            'google-cloud-sdk'
            'googletest'
            'gseapy'
            'haskell-cabal'
            'haskell-ghcup'
            'julia'
            'libarchive'
            'libsolv'
            'llvm'
            'mamba'
            # > 'nim'
            'nlohmann-json'
            'pybind11'
            'r-devel'
            'reproc'
            'rust'
            'spdlog'
            'termcolor'
            'tl-expected'
            'yaml-cpp'
        )
        if ! koopa_is_aarch64
        then
            apps+=(
                'agat'
                'anaconda'
                'autodock'
                'autodock-vina'
                'bamtools'
                'bedtools'
                'bioawk'
                # > 'bioconda-utils'
                'bowtie2'
                'bustools'
                'deeptools'
                'fastqc'
                'ffq'
                'fgbio'
                'fq'
                'fqtk'
                'gatk'
                'gffutils'
                'gget'
                # > 'haskell-stack'
                'hisat2'
                'htseq'
                'kallisto'
                'minimap2'
                # > 'misopy'
                'multiqc'
                'nanopolish'
                'nextflow'
                'openbb'
                'picard'
                'rsem'
                'salmon'
                'sambamba'
                'samtools'
                'scalene'
                'seqkit'
                'snakefmt'
                'snakemake'
                'sra-tools'
                'star'
                'star-fusion'
                'subread'
                'umis'
            )
        fi
        if koopa_is_linux
        then
            apps+=(
                'apptainer'
                'aspera-connect'
                'lmod'
            )
        fi
    fi
    koopa_add_to_path_start '/usr/local/bin'
    "${app['koopa']}" install 'aws-cli'
    for app_name in "${apps[@]}"
    do
        "${app['koopa']}" install --binary "$app_name"
    done
    return 0
}
