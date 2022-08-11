#!/usr/bin/env bash

# FIXME Finalize labeling all dependencies in this build script.
# Indicate the dependencies above each install command here.

koopa_build_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2022-08-11.
    #
    # The approach calling 'koopa_cli_install' internally on pkgs array
    # can run into weird compilation issues on macOS.
    #
    # @section Bootstrap workaround for macOS:
    # > /opt/koopa/include/bootstrap.sh
    # > PATH="${TMPDIR}/koopa-bootstrap/bin:${PATH}"
    # """
    local app dict pkg pkgs
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [koopa]="$(koopa_locate_koopa)"
    )
    [[ -x "${app[koopa]}" ]] || return 1
    declare -A dict=(
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pkgs=()
    pkgs+=(
        # deps: none.
        'pkg-config'
        # deps: none.
        'make'
    )
    koopa_is_linux && pkgs+=(
        # deps: none
        'attr'
    )
    pkgs+=(
        'patch'
        'xz'
        'm4'
        'gmp'
        'gperf'
        'mpfr'
        'mpc'
        'gcc'
        'autoconf'
        'automake'
        'libtool'
        'bison'
        'bash'
        'coreutils'
        'findutils'
        'sed'
        'ncurses'
        'icu4c'
        'readline'
        'libxml2'
        'gettext'
        # NOTE Consider moving this up in priority.
        'zlib'
        # FIXME Ensure this is added to install all apps.
        'ca-certificates'
        'openssl1'
        'openssl3'
        'cmake'
        'curl'
        'git'
        'lapack'
        'libffi'
        'libjpeg-turbo'
        'libpng'
        # NOTE Consider moving this up, under zlib.
        'zstd'
        'libtiff'
        'openblas'
        'bzip2'
        'pcre'
        'pcre2'
        'expat'
        'gdbm'
        'sqlite'
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
        'r'
        'conda'
        'apr'
        'apr-util'
        'armadillo'
        'aspell'
        'bc'
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
        'gawk'
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
    koopa_is_linux && pkgs+=('pinentry')
    pkgs+=(
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
        'libuv'
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
        'serf' # deps: scons
        'ruby' # deps: openssl3, zlib
        'subversion' # deps: ruby, serf
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tar'
        'tree'
        'udunits'
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
        # Install Python packages.
        'black'
        'bpytop'
        'flake8'
        'glances'
        'ipython'
        'isort'
        'latch'
        'poetry'
        'pipx'
        'pyflakes'
        'pygments'
        'ranger-fm'
        'yt-dlp'
        # NOTE Can consider using 'node-binary' here instead.
        'node'
        'bash-language-server' # deps: node
        'gtop' # deps: node
        'prettier' # deps: node
        # Install Perl packages.
        'ack' # deps: perl
        'rename' # deps: perl
        # Install Ruby packages.
        'bashcov' # deps: ruby
        'colorls' # deps: ruby
        'ronn' # deps: ruby
        'rust' # deps: ruby
        'bat' # deps: rust
        'broot' # deps: rust
        'delta' # deps: rust
        'difftastic' # deps: rust
        # > 'dog' # deps: rust
        'du-dust' # deps: rust
        'exa' # deps: rust
        'fd-find' # deps: rust
        'hyperfine' # deps: rust
        'mcfly' # deps: rust
        'mdcat' # deps: rust
        'procs' # deps: rust
        'ripgrep' # deps: rust
        'starship' # deps: rust
        'tealdeer' # deps: rust
        'tokei' # deps: rust
        'tuc' # deps: rust
        'xsv' # deps: rust
        'zellij' # deps: rust
        'zoxide' # deps: rust
        # NOTE Move this up.
        'julia'
        'ffq' # deps: conda
        'gget' # deps: conda
        'chemacs' # deps: go
        # deps: chemacs (to configure).
        'dotfiles'
    )
    if ! koopa_is_aarch64
    then
        pkgs+=(
            'anaconda'
            'haskell-stack'
            'hadolint' # deps: haskell-stack
            'pandoc' # deps: haskell-stack
            'kallisto' # deps: conda
            'salmon' # deps: conda
            'snakemake' # deps: conda
        )
    fi
    if koopa_is_linux
    then
        pkgs+=(
            'apptainer'
            'lmod'
        )
        if ! koopa_is_aarch64
        then
            pkgs+=(
                'aspera-connect'
                # FIXME Consider renaming / reworking this recipe...helpers.
                'docker-credential-pass'
            )
        fi
    fi

    # FIXME Double check which conda recipes aren't available on aarch64
    # e.g. bioconda
    pkgs+=(
        'libedit'
        'openssh' # deps: libedit
        'bamtools'
        'bedtools'
        'bioawk'
        'bowtie2'
        'bustools'
        'cheat'
        'deeptools'
        'ensembl-perl-api'
        'entrez-direct'
        'fastqc'
        'gffutils'
        'ghostscript'
        'gseapy'
        'hisat2'
        'jupyterlab'
        'multiqc'
        'nextflow'
        'pyenv'
        'pylint'
        'r-devel'
        'rbenv'
        'sambamba'
        'samtools'
        'sra-tools'
        'star'
        'visidata'
        'yq'
    )
    # App package libraries aren't supported as binary downloads, so keep
    # this step disabled.
    # > pkgs+=('julia-packages' 'r-packages')
    # This approach runs into compiler issues on macOS.
    # > koopa_cli_install "${pkgs[@]}"
    for pkg in "${pkgs[@]}"
    do
        # FIXME Consider defining this as 'koopa_is_symlink'.
        # FIXME Only do this if symlink exists.
        if [[ -L "${dict[opt_prefix]}/${pkg}" ]] && \
            [[ -e "${dict[opt_prefix]}/${pkg}" ]]
        then
            continue
        fi
        "${app[koopa]}" install "$pkg"
        # FIXME Consider asserting that the opt prefix isn't empty
        # after this step completes. Need to work this into the main
        # 'install_app' command.
    done
    # FIXME Enable this last step once our recipe works.
    # > koopa_push_all_apps
    return 0
}
