#!/usr/bin/env bash

koopa_build_all_apps() {
    # """
    # Build and install all koopa apps from source.
    # @note Updated 2022-08-10.
    #
    # @section Bootstrap workaround for macOS:
    # > /opt/koopa/include/bootstrap.sh
    # > PATH="${TMPDIR}/koopa-bootstrap/bin:${PATH}"
    # """
    local pkgs
    koopa_assert_has_no_args "$#"
    pkgs=()
    pkgs+=('pkg-config' 'make')
    koopa_is_linux && pkgs+=('attr')
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
        'fribidi'
        'gdbm'
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
        'harfbuzz'
        'hyperfine'
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
        'serf'
        'subversion'
        'shellcheck'
        'shunit2'
        'sox'
        'stow'
        'tar'
        'tokei' # FIXME Rust
        'tree'
        'tuc' # FIXME Rust
        'udunits'
        'units'
        'wget'
        'which'
        'libgeotiff'
        # FIXME Need to finish out recipe here.
        # Install Go packages.
        'go'
        'apptainer'
        'chezmoi'
        'fzf'
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
        'scons'
        'serf'
        'yt-dlp'
        # Install Node packages.
        'node'
        'bash-language-server'
        'gtop'
        'prettier'
        # Install Perl packages.
        'ack'
        'rename'
        # Install Ruby packages.
        'ruby'
        'bashcov'
        'colorls'
        'ronn'
        'rust'
        'bat' # deps: rust
        'broot' # deps: rust
        'delta' # deps: rust
        'difftastic' # deps: rust
        # > 'dog' # deps: rust
        'du-dust' # deps: rust
        'exa' # deps: rust
        'mcfly' # deps: rust
        'mdcat' # deps: rust
        'procs' # deps: rust
        'ripgrep' # deps: rust
        'starship' # deps: rust
        'tealdeer' # deps: rust
        'tokei' # deps: rust
        'xsv' # deps: rust
        'zellij' # deps: rust
        'zoxide' # deps: rust
        'julia'
        'ffq' # deps: conda
        'gget' # deps: conda
        'chemacs' # deps: go
        'dotfiles' # deps: chemacs
    )
    if ! koopa_is_aarch64
    then
        pkgs+=(
            'anaconda'
            'aspera-connect'
            # FIXME Consider renaming / reworking this recipe...helpers.
            'docker-credential-pass'
            'hadolint'
            'haskell-stack'
            'kallisto'
            'pandoc'
            'salmon'
            'snakemake'
        )
    fi
    koopa_is_linux && pkgs+=('lmod')
    # App package libraries aren't supported as binary downloads, so keep
    # this step disabled.
    # > pkgs+=('julia-packages' 'r-packages')
    # FIXME This approach is problematic on macOS.
    # > koopa_cli_install "${pkgs[@]}"
    local app pkg
    declare -A app=(
        [koopa]="$(koopa_locate_koopa)"
    )
    [[ -x "${app[koopa]}" ]] || return 1
    for pkg in "${pkgs[@]}"
    do
        "${app[koopa]}" install "$pkg"
    done
    koopa_push_all_apps
    return 0
}
