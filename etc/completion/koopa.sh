#!/usr/bin/env bash
# shellcheck disable=SC2207

__koopa_complete() { # {{{1
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # Updated 2022-03-22.
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
                'list'
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
                        'bowtie2'
                        'conda'
                        'docker'
                        'ftp'
                        'git'
                        'gpg'
                        'kallisto'
                        'list'
                        'python'
                        'r'
                        'rnaeditingindexer'
                        'salmon'
                        'sra'
                        'ssh'
                        'star'
                        'wget'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'clean'
                            'link'
                            'unlink'
                        )
                    fi
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
                        'autoconf'
                        'automake'
                        'bash'
                        'binutils'
                        'chemacs'
                        'cmake'
                        'conda'
                        'coreutils'
                        'cpufetch'
                        'curl'
                        'doom-emacs'
                        'dotfiles'
                        'emacs'
                        'ensembl-perl-api'
                        'findutils'
                        'fish'
                        'fzf'
                        'gawk'
                        'gcc'
                        'gdal'
                        'geos'
                        'git'
                        'gnupg'
                        'go'
                        'grep'
                        'groff'
                        'gsl'
                        'haskell-stack'
                        'hdf5'
                        'homebrew'
                        'homebrew-bundle'
                        'htop'
                        'imagemagick'
                        'julia'
                        'julia-packages'
                        'lesspipe'
                        'libevent'
                        'libtool'
                        'lua'
                        'luarocks'
                        'make'
                        'mamba'
                        'ncurses'
                        'neofetch'
                        'neovim'
                        'nim'
                        'nim-packages'
                        'node-packages'
                        'openjdk'
                        'openssh'
                        'openssl'
                        'parallel'
                        'password-store'
                        'patch'
                        'perl'
                        'perl-packages'
                        'perlbrew'
                        'pkg-config'
                        'prelude-emacs'
                        'proj'
                        'pyenv'
                        'python'
                        'python-packages'
                        'r'
                        'r-cmd-check'
                        'r-packages'
                        'rbenv'
                        'rmate'
                        'rsync'
                        'ruby'
                        'ruby-packages'
                        'rust'
                        'rust-packages'
                        'sed'
                        'shellcheck'
                        'shunit2'
                        'singularity'
                        'spacemacs'
                        'spacevim'
                        'sqlite'
                        'subversion'
                        'taglib'
                        'tar'
                        'texinfo'
                        'the-silver-searcher'
                        'tmux'
                        'udunits'
                        'vim'
                        'wget'
                        'zsh'
                    )
                    if koopa_is_linux
                    then
                        args+=(
                            'aspera-connect'
                            'aws-cli'
                            'azure-cli'
                            'base-system'
                            'bcbio-nextgen'
                            'bcl2fastq'
                            'cellranger'
                            'cloudbiolinux'
                            'docker-credential-pass'
                            'google-cloud-sdk'
                            'julia'
                            'lmod'
                            'pihole'
                            'pivpn'
                            'rstudio-server'
                            'rstudio-workbench'
                            'shiny-server'
                            'wine'
                        )
                        if koopa_is_debian_like
                        then
                            args+=(
                                'bcbio-nextgen-vm'
                                'node'
                                'pandoc'
                                'r-cran-binary'
                                'r-devel'
                            )
                        elif koopa_is_fedora_like
                        then
                            args+=(
                                'oracle-instant-client'
                            )
                        fi
                    fi
                    if koopa_is_macos
                    then
                        args+=(
                            'adobe-creative-cloud'
                            'cisco-webex'
                            'microsoft-onedrive'
                            'oracle-java'
                            'python-framework'
                            'r-cran-gfortran'
                            'r-framework'
                            'ringcentral'
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
                'list')
                    args=(
                        'app-versions'
                        'dotfiles'
                        'path-priority'
                        'programs'
                    )
                    ;;
                'system')
                    args=(
                        'brew-dump-brewfile'
                        'brew-outdated'
                        'check'
                        'delete-cache'
                        'disable-passwordless-sudo'
                        'enable-passwordless-sudo'
                        'find-non-symlinked-make-files'
                        'fix-sudo-setrlimit-error'
                        'fix-zsh-permissions'
                        'host-id'
                        'info'
                        'log'
                        'os-string'
                        'prefix'
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
                            'disable-touch-id-sudo'
                            'enable-touch-id-sudo'
                            'flush-dns'
                            'homebrew-cask-version'
                            'ifactive'
                            'list-launch-agents'
                            'macos-app-version'
                            'reload-autofs'
                        )
                    fi
                    ;;
                'update')
                    args=(
                        # koopa:
                        'koopa'
                        'system'
                        # packages:
                        'chemacs'
                        'doom-emacs'
                        'dotfiles'
                        'google-cloud-sdk'
                        'homebrew'
                        'mamba'
                        'nim-packages'
                        'node-packages'
                        'perl-packages'
                        'prelude-emacs'
                        'pyenv'
                        'python-packages'
                        'r-packages'
                        'rbenv'
                        'ruby-packages'
                        'rust'
                        'rust-packages'
                        'spacemacs'
                        'spacevim'
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
                'app')
                    case "${COMP_WORDS[COMP_CWORD-1]}" in
                        'aws')
                            args=(
                                'batch'
                                'ec2'
                                's3'
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
                        'python')
                            args=(
                                'create-venv'
                                'pip-outdated'
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
