#!/usr/bin/env bash
# shellcheck disable=SC2207

__koopa_complete() { # {{{1
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # Updated 2022-04-20.
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
            args=(
                '--help'
                '--version'
                'app'
                'configure'
                'header'
                'install'
                'reinstall'
                'system'
                'uninstall'
                'update'
            )
            ;;
        '2')
            case "${COMP_WORDS[COMP_CWORD-1]}" in
                'app')
                    args=(
                        'aws'
                        'bioconda'
                        'bowtie2'
                        'conda'
                        'docker'
                        'ftp'
                        'git'
                        'gpg'
                        'kallisto'
                        'r'
                        'rnaeditingindexer'
                        'salmon'
                        'sra'
                        'ssh'
                        'star'
                        'wget'
                    )
                    ;;
                'configure')
                    args=(
                        'chemacs'
                        'dotfiles'
                        'go'
                        'julia'
                        'nim'
                        'node'
                        'perl'
                        'python'
                        'r'
                        'ruby'
                        'rust'
                    )
                    ;;
                'header')
                    args=(
                        'bash'
                        'posix'
                        'r'
                        'zsh'
                    )
                    ;;
                'install' | \
                'reinstall' | \
                'uninstall')
                    args=(
                        'anaconda'
                        'apr'
                        'apr-util'
                        'armadillo'
                        'attr'
                        'autoconf'
                        'automake'
                        'aws-cli'
                        'bash'
                        'bat'
                        'bc'
                        'binutils'
                        'black'
                        'boost'
                        'bpytop'
                        'broot'
                        'chemacs'
                        'cmake'
                        'conda'
                        'coreutils'
                        'cpufetch'
                        'curl'
                        'difftastic'
                        'doom-emacs'
                        'dotfiles'
                        'du-dust'
                        'emacs'
                        'ensembl-perl-api'
                        'exa'
                        'fd-find'
                        'findutils'
                        'fish'
                        'flake8'
                        'fltk'
                        'freetype'
                        'fribidi'
                        'fzf'
                        'gawk'
                        # > 'gcc'
                        # > 'gdal'
                        # > 'geos'
                        'gettext'
                        'git'
                        'glances'
                        'gmp'
                        'gnupg'
                        'go'
                        'grep'
                        'groff'
                        'gsl'
                        'hadolint'
                        'harfbuzz'
                        'haskell-stack'
                        'hdf5'
                        'homebrew'
                        'homebrew-bundle'
                        'htop'
                        'hyperfine'
                        'icu4c'
                        'imagemagick'
                        'jpeg'
                        'jq'
                        'julia'
                        'julia-packages'
                        'koopa'
                        'lesspipe'
                        'libevent'
                        'libgeotiff'
                        'libgit2'
                        'libjpeg-turbo'
                        'libpng'
                        'libssh2'
                        'libtasn1'
                        'libtiff'
                        'libtool'
                        'libunistring'
                        'libxml2'
                        'libzip'
                        'lua'
                        'luarocks'
                        'make'
                        'mamba'
                        'man-db'
                        'mcfly'
                        'meson'
                        'ncurses'
                        'neofetch'
                        'neovim'
                        'nettle'
                        'nim'
                        'nim-packages'
                        'ninja'
                        'node'
                        'node-binary'
                        'node-packages'
                        'oniguruma'
                        'openjdk'
                        'openssh'
                        'openssl'
                        'pandoc'
                        'parallel'
                        'password-store'
                        'patch'
                        'pcre'
                        'pcre2'
                        'perl'
                        'perl-packages'
                        'perlbrew'
                        'pipx'
                        'pkg-config'
                        'prelude-emacs'
                        'procs'
                        # > 'proj'
                        'pyenv'
                        'pyflakes'
                        'pylint'
                        'pytest'
                        'python'
                        'python-packages'
                        'r'
                        'r-cmd-check'
                        'r-devel'
                        'r-packages'
                        'ranger-fm'
                        'rbenv'
                        'ripgrep'
                        # > 'ripgrep-all'
                        'rmate'
                        'rsync'
                        'ruby'
                        'ruby-packages'
                        'rust'
                        'scons'
                        'sed'
                        'serf'
                        'shellcheck'
                        'shunit2'
                        'singularity'
                        'spacemacs'
                        'spacevim'
                        'sqlite'
                        'starship'
                        'stow'
                        'subversion'
                        'taglib'
                        'tar'
                        'tealdeer'
                        'texinfo'
                        # > 'the-silver-searcher'
                        'tmux'
                        'tokei'
                        'tree'
                        'udunits'
                        'vim'
                        'wget'
                        'which'
                        'xsv'
                        'xz'
                        'zlib'
                        'zoxide'
                        'zsh'
                        'zstd'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'aspera-connect'
                            'azure-cli'
                            'base-system'
                            'bcbio-nextgen'
                            'bcl2fastq'
                            'cellranger'
                            'cloudbiolinux'
                            'docker-credential-pass'
                            'google-cloud-sdk'
                            'julia-binary'
                            'lmod'
                            'node-binary'
                            'pihole'
                            'pivpn'
                            'wine'
                        )
                        if koopa_is_debian_like || koopa_is_fedora_like
                        then
                            args+=(
                                'rstudio-server'
                                'rstudio-workbench'
                                'shiny-server'
                            )
                            if koopa_is_debian_like
                            then
                                args+=(
                                    'bcbio-nextgen-vm'
                                    'pandoc-binary'
                                    'r-binary'
                                )
                            elif koopa_is_fedora_like
                            then
                                args+=(
                                    'oracle-instant-client'
                                )
                            fi
                        fi 
                    fi
                    if koopa_is_macos
                    then
                        args+=(
                            'neovim-binary'
                            'python-binary'
                            'r-binary'
                            'r-gfortran'
                            'r-openmp'
                            'xcode-clt'
                        )
                    fi
                    # Handle 'install' or 'uninstall'-specific arguments.
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'install' | \
                        'reinstall')
                            args+=(
                                'homebrew-bundle'
                                'tex-packages'
                            )
                            ;;
                        'uninstall')
                            args+=(
                                'koopa'
                            )
                            ;;
                    esac
                    ;;
                'system')
                    args=(
                        'brew-dump-brewfile'
                        'brew-outdated'
                        'cache-bash-functions' # FIXME Add support.
                        'check'
                        'delete-cache'
                        'disable-passwordless-sudo'
                        'enable-passwordless-sudo'
                        'find-non-symlinked-make-files'
                        'fix-sudo-setrlimit-error'
                        'fix-zsh-permissions'
                        'host-id'
                        'info'
                        'list'
                        'log'
                        'os-string'
                        'prefix'
                        'push-app-build'
                        'reload-shell'
                        'roff'
                        'set-permissions'
                        'switch-to-develop'
                        'test'
                        'variables'
                        'version'
                        'which'
                    )
                    if koopa_is_macos
                    then
                        args+=(
                            'clean-launch-services'
                            'create-dmg'
                            'disable-touch-id-sudo'
                            'enable-touch-id-sudo'
                            'flush-dns'
                            'force-eject'
                            'homebrew-cask-version'
                            'ifactive'
                            'macos-app-version'
                            'reload-autofs'
                            'spotlight'
                        )
                    fi
                    ;;
                'update')
                    args=(
                        'chemacs'
                        'doom-emacs'
                        'dotfiles'
                        'google-cloud-sdk'
                        'homebrew'
                        'koopa'
                        'mamba'
                        'nim-packages'
                        'node-packages'
                        'perl-packages'
                        'prelude-emacs'
                        'python-packages'
                        'r-packages'
                        'ruby-packages'
                        'rust-packages'
                        'spacemacs'
                        'spacevim'
                        'system'
                        'tex-packages'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'google-cloud-sdk'
                        )
                    elif koopa_is_macos
                    then
                        args+=(
                            'defaults'
                            'microsoft-office'
                        )
                    fi
                    ;;
                *)
                    ;;
            esac
            ;;
        '3')
            case "${COMP_WORDS[COMP_CWORD-2]}" in
                'system')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                    'list')
                        args=(
                            'app-versions'
                            'dotfiles'
                            'path-priority'
                            'programs'
                        )
                        if koopa_is_macos
                        then
                            args+=('launch-agents') # FIXME Support this.
                        fi
                        ;;
                    esac
                    ;;
                'app')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'aws')
                            args=(
                                'batch'
                                'ec2'
                                's3'
                            )
                            ;;
                        'bioconda')
                            args=(
                                'autobump-recipe'
                            )
                            ;;
                        'bowtie2' | \
                        'star')
                            args=(
                                'align'
                                'index'
                            )
                            ;;
                        'conda')
                            args=(
                                'create-env'
                                'remove-env'
                            )
                            ;;
                        'docker')
                            args=(
                                'build'
                                'build-all-images'
                                'build-all-tags'
                                'prune-all-images'
                                'prune-all-stale-tags'
                                'prune-old-images'
                                'prune-stale-tags'
                                'push'
                                'remove'
                                'run'
                                'tag'
                            )
                            ;;
                        'ftp')
                            args=(
                                'mirror'
                            )
                            ;;
                        'git')
                            args=(
                                'checkout-recursive'
                                'pull'
                                'pull-recursive'
                                'push-recursive'
                                'push-submodules'
                                'rename-master-to-main'
                                'reset'
                                'reset-fork-to-upstream'
                                'rm-submodule'
                                'rm-untracked'
                                'status-recursive'
                            )
                            ;;
                        'gpg')
                            args=(
                                'prompt'
                                'reload'
                                'restart'
                            )
                            ;;
                        'jekyll')
                            args=(
                                'serve'
                            )
                            ;;
                        'kallisto' | \
                        'salmon')
                            args=(
                                'index'
                                'quant'
                            )
                            ;;
                        'md5sum')
                            args=(
                                'check-to-new-md5-file'
                            )
                            ;;
                        'r')
                            args=(
                                'drat'
                                'pkgdown-deploy-to-aws'
                                'shiny-run-app'
                            )
                            ;;
                        'sra')
                            args=(
                                'download-accession-list'
                                'download-run-info-table'
                                'fastq-dump'
                                'prefetch'
                            )
                            ;;
                        'ssh')
                            args=(
                                'generate-key'
                            )
                            ;;
                        'wget')
                            args=(
                                'recursive'
                            )
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
                                    args=(
                                        'fetch-and-run'
                                        'list-jobs'
                                    )
                                    ;;
                                'ec2')
                                    args=(
                                        'instance-id'
                                        'suspend'
                                        # > 'terminate'
                                    )
                                    ;;
                                's3')
                                    args=(
                                        'find'
                                        'list-large-files'
                                        'ls'
                                        'mv-to-parent'
                                        'sync'
                                    )
                                    ;;
                            esac
                            ;;
                        'kallisto' | \
                        'salmon')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'quant')
                                    args=(
                                        'paired-end'
                                        'single-end'
                                    )
                                    ;;
                            esac
                            ;;
                        'star')
                            case "${COMP_WORDS[COMP_CWORD-1]}" in
                                'align')
                                    args=(
                                        'paired-end'
                                        'single-end'
                                    )
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

complete -F __koopa_complete koopa
