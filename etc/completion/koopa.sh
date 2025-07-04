#!/usr/bin/env bash
# shellcheck disable=SC2207

_koopa_complete() {
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # @note Updated 2025-06-11.
    #
    # Keep all of these commands in a single file.
    # Sourcing multiple scripts doesn't work reliably.
    #
    # Multi-level bash completion:
    # - https://stackoverflow.com/questions/17879322/
    # - https://stackoverflow.com/questions/5302650/
    #
    # @seealso
    # - https://github.com/scop/bash-completion/
    # - https://www.gnu.org/software/bash/manual/html_node/
    #     A-Programmable-Completion-Example.html
    # - https://iridakos.com/programming/2018/03/01/
    #     bash-programmable-completion-tutorial
    # - https://devmanual.gentoo.org/tasks-reference/completion/index.html
    # """
    local args
    COMPREPLY=()
    case "${COMP_CWORD:-}" in
        '1')
            args+=(
                '--help'
                '--version'
                'app'
                'configure'
                'develop'
                'header'
                'install'
                'install-all-apps'
                'install-default-apps'
                'reinstall'
                'system'
                'uninstall'
                'update'
            )
            ;;
        '2')
            case "${COMP_WORDS[COMP_CWORD-1]}" in
                'app')
                    args+=(
                        'aws'
                        'bioconda'
                        'bowtie2'
                        'brew'
                        'conda'
                        'docker'
                        'ftp'
                        'git'
                        'gpg'
                        'hisat2'
                        'jekyll'
                        'kallisto'
                        'miso'
                        'r'
                        'rmats'
                        'rnaeditingindexer'
                        'rsem'
                        'salmon'
                        'sra'
                        'ssh'
                        'star'
                        'wget'
                        'wget2'
                    )
                    ;;
                'configure')
                    args+=('system' 'user')
                    ;;
                'develop')
                    args+=(
                        'cache-functions'
                        'edit-app-json'
                        'log'
                        'prune-app-binaries'
                        'push-all-app-builds'
                        'push-app-build'
                        'roff'
                    )
                    ;;
                'header')
                    args+=('bash' 'posix' 'zsh')
                    ;;
                'install' | \
                'reinstall' | \
                'uninstall')
                    args+=(
                        'ack'
                        'agat'
                        'air'
                        'anaconda'
                        'apache-airflow'
                        'apache-arrow'
                        'apache-spark'
                        'apr'
                        'apr-util'
                        'aria2'
                        'armadillo'
                        'asdf'
                        'aspell'
                        'attr'
                        'autoconf'
                        'autodock'
                        'autodock-adfr'
                        'autodock-vina'
                        'autoflake'
                        'automake'
                        'aws-azure-login'
                        'aws-cli'
                        'azure-cli'
                        'bamtools'
                        'bandit'
                        'bandwhich'
                        'bash'
                        'bash-completion'
                        'bash-language-server'
                        'bashcov'
                        'bat'
                        'bc'
                        'bedtools'
                        'bfg'
                        'binutils'
                        'bioawk'
                        'bioconda-utils'
                        'bison'
                        'black'
                        'blast'
                        'boost'
                        'bottom'
                        'bowtie2'
                        'bpytop'
                        'broot'
                        'brotli'
                        'bustools'
                        'byobu'
                        'bzip2'
                        'c-ares'
                        'ca-certificates'
                        'cairo'
                        'cereal'
                        'cheat'
                        'chezmoi'
                        'cli11'
                        'cmake'
                        'colorls'
                        'commitizen'
                        'conda'
                        'coreutils'
                        'cpufetch'
                        'csvkit'
                        'csvtk'
                        'curl'
                        'dash'
                        'deeptools'
                        'delta'
                        'diff-so-fancy'
                        'difftastic'
                        'direnv'
                        'docker-credential-helpers'
                        'dotfiles'
                        'du-dust'
                        'duckdb'
                        'ed'
                        'editorconfig'
                        'emacs'
                        'ensembl-perl-api'
                        'entrez-direct'
                        'exiftool'
                        'expat'
                        'eza'
                        'fastqc'
                        'fd-find'
                        'ffmpeg'
                        'ffq'
                        'fgbio'
                        'findutils'
                        'fish'
                        'flac'
                        'flake8'
                        'flex'
                        'fltk'
                        'fmt'
                        'fontconfig'
                        'fq'
                        'fqtk'
                        'freetype'
                        'fribidi'
                        'fzf'
                        'gatk'
                        'gawk'
                        'gdal'
                        'gdbm'
                        'genomepy'
                        'gentropy'
                        'geos'
                        'gettext'
                        'gffutils'
                        'gget'
                        'gh'
                        'ghostscript'
                        'git'
                        'git-filter-repo'
                        'git-lfs'
                        'gitui'
                        'glances'
                        'glib'
                        'gmp'
                        'gnupg'
                        'gnutls'
                        'go'
                        'google-cloud-sdk'
                        'googletest'
                        'gperf'
                        'graphviz'
                        'grep'
                        'grex'
                        'groff'
                        'gseapy'
                        'gsl'
                        'gtop'
                        'gum'
                        'gzip'
                        'hadolint'
                        'harfbuzz'
                        'haskell-cabal'
                        'haskell-ghcup'
                        'haskell-stack'
                        'hdf5'
                        'hexyl'
                        'hisat2'
                        'htop'
                        'htseq'
                        'htslib'
                        'httpie'
                        'httpx'
                        'huggingface-hub'
                        'hugo'
                        'hyperfine'
                        'icu4c'
                        'imagemagick'
                        'ipython'
                        'isl'
                        'isort'
                        'jemalloc'
                        'jfrog-cli'
                        'jless'
                        'jpeg'
                        'jq'
                        'julia'
                        'jupyterlab'
                        'kallisto'
                        'koopa'
                        'krb5'
                        'ksh93'
                        'lame'
                        'lapack'
                        'latch'
                        'ldc'
                        'ldns'
                        'lesspipe'
                        'libaec'
                        'libarchive'
                        'libassuan'
                        'libcbor'
                        'libconfig'
                        'libde265'
                        'libdeflate'
                        'libedit'
                        'libev'
                        'libevent'
                        'libffi'
                        'libfido2'
                        'libgcrypt'
                        'libgeotiff'
                        'libgit2'
                        'libgpg-error'
                        'libheif'
                        'libiconv'
                        'libjpeg-turbo'
                        'libksba'
                        'liblinear'
                        'libluv'
                        'libpcap'
                        'libpipeline'
                        'libpng'
                        'libsolv'
                        'libssh2'
                        'libtasn1'
                        'libtermkey'
                        'libtiff'
                        'libtool'
                        'libunistring'
                        'libuv'
                        'libvterm'
                        'libxcrypt'
                        'libxml2'
                        'libxslt'
                        'libyaml'
                        'libzip'
                        'llvm'
                        'lsd'
                        'lua'
                        'luajit'
                        'luarocks'
                        'luigi'
                        'lz4'
                        'lzip'
                        'lzo'
                        'm4'
                        'make'
                        'mamba'
                        'man-db'
                        'marimo'
                        'markdownlint-cli'
                        'mcfly'
                        'mdcat'
                        'meson'
                        'miller'
                        'mimalloc'
                        'minimap2'
                        'misopy'
                        'mold'
                        'mosaicml-cli'
                        'mpc'
                        'mpdecimal'
                        'mpfr'
                        'msgpack'
                        'multiqc'
                        'mutagen'
                        'mypy'
                        'nano'
                        'nanopolish'
                        'ncbi-sra-tools'
                        'ncbi-vdb'
                        'ncurses'
                        'neofetch'
                        'neovim'
                        'nettle'
                        'nextflow'
                        'nghttp2'
                        'nim'
                        'ninja'
                        'nlohmann-json'
                        'nmap'
                        'node'
                        'npth'
                        'nushell'
                        'oniguruma'
                        'ont-dorado'
                        'ont-vbz-compression'
                        'openblas'
                        'openjpeg'
                        'openldap'
                        'openssh'
                        'openssl3'
                        'p7zip'
                        'pandoc'
                        'parallel'
                        'password-store'
                        'patch'
                        'pbzip2'
                        'pcre'
                        'pcre2'
                        'perl'
                        'picard'
                        'pigz'
                        'pinentry'
                        'pipx'
                        'pixman'
                        'pkg-config'
                        'pkgconf'
                        'poetry'
                        'postgresql'
                        'prettier'
                        'private'
                        'procs'
                        'proj'
                        'pup'
                        'py-spy'
                        'pybind11'
                        'pycodestyle'
                        'pyenv'
                        'pyflakes'
                        'pygments'
                        'pylint'
                        'pymol'
                        'pyrefly'
                        'pyright'
                        'pytaglib'
                        'pytest'
                        'python3.10'
                        'python3.11'
                        'python3.12'
                        'python3.13'
                        'quarto'
                        'r'
                        'r-devel'
                        'radian'
                        'ranger-fm'
                        'rbenv'
                        'rclone'
                        'readline'
                        'rename'
                        'reproc'
                        'ripgrep'
                        'ripgrep-all'
                        'rmate'
                        'rmats'
                        # > 'ronn'
                        'ronn-ng'
                        'rsem'
                        'rsync'
                        'ruby'
                        'ruff'
                        'ruff-lsp'
                        'rust'
                        's5cmd'
                        'salmon'
                        'sambamba'
                        'samtools'
                        'scalene'
                        'scanpy'
                        'scons'
                        'screen'
                        'sd'
                        'sed'
                        'seqkit'
                        'serf'
                        'shellcheck'
                        'shunit2'
                        'shyaml'
                        'simdjson'
                        'snakefmt'
                        'snakemake'
                        'sox'
                        'spdlog'
                        'sphinx'
                        'sqlfluff'
                        'sqlite'
                        'staden-io-lib'
                        'star'
                        'starship'
                        'stow'
                        'streamlit'
                        'subread'
                        'subversion'
                        'swig'
                        'taglib'
                        'tar'
                        'tbb'
                        'tcl-tk'
                        'tealdeer'
                        'temurin'
                        'termcolor'
                        'texinfo'
                        'tl-expected'
                        'tmux'
                        'tokei'
                        'tqdm'
                        'tree'
                        'tree-sitter'
                        'tryceratops'
                        'tuc'
                        'ty'
                        'udunits'
                        'umis'
                        'unibilium'
                        'units'
                        'unzip'
                        'utf8proc'
                        'uv'
                        'vim'
                        'visidata'
                        'vulture'
                        'walk'
                        'wget'
                        'which'
                        'woff2'
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
                        'xsra'
                        'xsv'
                        'xxhash'
                        'xz'
                        'yaml-cpp'
                        'yapf'
                        'yt-dlp'
                        'zellij'
                        'zenith'
                        'zip'
                        'zlib'
                        'zopfli'
                        'zoxide'
                        'zsh'
                        'zstd'
                    )
                    if _koopa_is_linux
                    then
                        args+=(
                            'apptainer'
                            'aspera-connect'
                            'cloudbiolinux'
                            'elfutils'
                            'gcc'
                            'lmod'
                            'ont-bonito'
                        )
                    fi
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'install' | \
                        'uninstall')
                            args+=('private' 'system' 'user')
                            ;;
                        'reinstall')
                            args+=('--all-revdeps' '--only-revdeps')
                            ;;
                    esac
                    ;;
                'system')
                    args+=(
                        'check'
                        'disable-passwordless-sudo'
                        'enable-passwordless-sudo'
                        'host-id'
                        'info'
                        'list'
                        'os-string'
                        'prefix'
                        'prune-apps'
                        'switch-to-develop'
                        'test'
                        'version'
                        'which'
                        'zsh-compaudit-set-permissions'
                    )
                    if _koopa_is_macos
                    then
                        args+=(
                            'clean-launch-services'
                            'create-dmg'
                            'disable-touch-id-sudo'
                            'enable-touch-id-sudo'
                            'flush-dns'
                            'force-eject'
                            'ifactive'
                            'reload-autofs'
                            'spotlight'
                        )
                    fi
                    ;;
                'update')
                    args+=('koopa' 'system')
                    ;;
                *)
                    ;;
            esac
            ;;
        '3')
            case "${COMP_WORDS[COMP_CWORD-2]}" in
                'configure')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'system')
                            args+=('r')
                            if _koopa_is_linux
                            then
                                args+=('lmod' 'rstudio-server' 'sshd')
                            fi
                            if _koopa_is_debian_like
                            then
                                args+=('base')
                            elif _koopa_is_macos
                            then
                                args+=('preferences')
                            fi
                            ;;
                        'user')
                            args+=('chemacs' 'dotfiles')
                            if _koopa_is_macos
                            then
                                args+=('preferences')
                            fi
                            ;;
                        esac
                    ;;
                'install' | \
                'uninstall')
                    case "${COMP_WORDS[COMP_CWORD-2]}" in
                        'install')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'system')
                                    args+=('homebrew-bundle' 'tex-packages')
                                    if _koopa_is_macos
                                    then
                                        args+=('rosetta')
                                    fi
                                    ;;
                            esac
                            ;;
                    esac
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'private')
                            args+=('ont-guppy')
                            if _koopa_is_linux
                            then
                                args+=('bcl2fastq' 'cellranger')
                            fi
                            ;;
                        'system')
                            args+=('homebrew')
                            if _koopa_is_linux
                            then
                                args+=('pihole' 'pivpn' 'wine')
                                if _koopa_is_debian_like || \
                                   _koopa_is_fedora_like
                                then
                                    args+=('rstudio-server' 'shiny-server')
                                fi
                                if _koopa_is_debian_like
                                then
                                    args+=('docker' 'r')
                                elif _koopa_is_fedora_like
                                then
                                    args+=('oracle-instant-client')
                                fi
                            elif _koopa_is_macos
                            then
                                args+=(
                                    'python'
                                    'r'
                                    'r-gfortran'
                                    'r-xcode-openmp'
                                    'xcode-clt'
                                )
                            fi
                            ;;
                        'user')
                            args+=(
                                'bootstrap'
                                'doom-emacs'
                                'prelude-emacs'
                                'spacemacs'
                                'spacevim'
                            )
                            ;;
                        esac
                        ;;
                'update')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'system')
                            args+=('homebrew' 'tex-packages')
                            ;;
                        esac
                        ;;
                'system')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'list')
                            args+=(
                                'app-versions'
                                'dotfiles'
                                'path-priority'
                                'programs'
                            )
                            if _koopa_is_macos
                            then
                                args+=('launch-agents')
                            fi
                            ;;
                        esac
                        ;;
                'app')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'aws')
                            args+=('batch' 'codecommit' 'ec2' 'ecr' 's3')
                            ;;
                        'bioconda')
                            args+=('autobump-recipe')
                            ;;
                        'bowtie2' | \
                        'hisat2' | \
                        'star')
                            args+=('align' 'index')
                            ;;
                        'brew')
                            args+=(
                                'cleanup'
                                'dump-brewfile'
                                'outdated'
                                'reset-core-repo'
                                'reset-permissions'
                                'uninstall-all-brews'
                                'upgrade-brews'
                                'version'
                            )
                            ;;
                        'conda')
                            args+=('create-env' 'remove-env')
                            ;;
                        'docker')
                            args+=(
                                'build'
                                'build-all-tags'
                                'prune-all-images'
                                'prune-old-images'
                                'remove'
                                'run'
                            )
                            ;;
                        'ftp')
                            args+=('mirror')
                            ;;
                        'git')
                            args+=(
                                'pull'
                                'push-submodules'
                                'rename-master-to-main'
                                'reset'
                                'reset-fork-to-upstream'
                                'rm-submodule'
                                'rm-untracked'
                            )
                            ;;
                        'gpg')
                            args+=('prompt' 'reload' 'restart')
                            ;;
                        'jekyll')
                            args+=('serve')
                            ;;
                        'kallisto' | \
                        'rsem')
                            args+=('index' 'quant')
                            ;;
                        'md5sum')
                            args+=('check-to-new-md5-file')
                            ;;
                        'miso')
                            args+=('index' 'run')
                            ;;
                        'r')
                            args+=('bioconda-check' 'check')
                            ;;
                        'salmon')
                            args+=('detect-fastq-library-type' 'index' 'quant')
                            ;;
                        'sra')
                            args+=(
                                'download-accession-list'
                                'download-run-info-table'
                                'fastq-dump'
                                'prefetch'
                            )
                            ;;
                        'ssh')
                            args+=('generate-key')
                            ;;
                        'wget')
                            args+=('recursive')
                            ;;
                    esac
                    ;;
            esac
            ;;
        '4')
            case "${COMP_WORDS[COMP_CWORD-3]}" in
                'app')
                    case "${COMP_WORDS[COMP_CWORD-2]}" in
                        'aws')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'batch')
                                    args+=('fetch-and-run' 'list-jobs')
                                    ;;
                                'codecommit')
                                    args+=('list-repositories')
                                    ;;
                                'ec2')
                                    args+=(
                                        'list-running-instances'
                                        'map-instance-ids-to-names'
                                    )
                                    if _koopa_is_linux
                                    then
                                        args+=(
                                            'instance-id'
                                            'stop'
                                        )
                                    fi
                                    ;;
                                'ecr')
                                    args+=('login-public' 'login-private')
                                    ;;
                                's3')
                                    args+=(
                                        'delete-versioned-glacier-objects'
                                        'delete-versioned-objects'
                                        'dot-clean'
                                        'find'
                                        'list-large-files'
                                        'ls'
                                        'mv-to-parent'
                                        'sync'
                                    )
                                    ;;
                            esac
                            ;;
                        'bowtie2')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'align')
                                    args+=('paired-end')
                                    ;;
                            esac
                            ;;
                        'hisat2' | \
                        'star')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'align')
                                    args+=('paired-end' 'single-end')
                                    ;;
                            esac
                            ;;
                        'kallisto')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'quant')
                                    args+=('paired-end' 'single-end')
                                    ;;
                            esac
                            ;;
                        'rsem')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'quant')
                                    args+=('bam')
                                    ;;
                            esac
                            ;;
                        'salmon')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'quant')
                                    args+=('bam' 'paired-end' 'single-end')
                                    ;;
                            esac
                            ;;
                    esac
                    ;;
            esac
            ;;
    esac
    # Quoting inside the array doesn't work for Bash, but does for Zsh.
    COMPREPLY=($(compgen -W "${args[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    return 0
}

complete -F _koopa_complete koopa
