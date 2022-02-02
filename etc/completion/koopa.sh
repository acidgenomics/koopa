#!/usr/bin/env bash
# shellcheck disable=SC2207

_koopa_complete() { # {{{1
    # """
    # Bash/Zsh TAB completion for primary 'koopa' program.
    # Updated 2022-02-02.
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
    [[ -n "${COMP_CWORD:-}" ]] || return 0
    case "${COMP_CWORD:?}" in
        '1')
            [[ "${COMP_WORDS[COMP_CWORD-1]}" == 'koopa' ]] || return 0
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
                'test'
                'uninstall'
                'update'
            )
            ;;
        '2')
            [[ "${COMP_WORDS[COMP_CWORD-2]}" == 'koopa' ]] || return 0
            case "${COMP_WORDS[COMP_CWORD-1]}" in
                'app')
                    args=(
                        'conda'
                        'list'
                    )
                    if _koopa_is_linux
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
                    if _koopa_is_linux
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
                        if _koopa_is_debian_like
                        then
                            args+=(
                                'bcbio-nextgen-vm'
                                'node'
                                'pandoc'
                                'r-cran-binary'
                                'r-devel'
                            )
                        elif _koopa_is_fedora_like
                        then
                            args+=(
                                'oracle-instant-client'
                            )
                        fi
                    fi
                    if _koopa_is_macos
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
                        'path'
                        'prefix'
                        'roff'
                        'set-permissions'
                        'switch-to-develop'
                        'variable'
                        'variables'
                        'version'
                        'which'
                    )
                    if _koopa_is_macos
                    then
                        args+=(
                            'disable-touch-id-sudo'
                            'enable-touch-id-sudo'
                            'homebrew-cask-version'
                            'macos-app-version'
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
                    if _koopa_is_linux
                    then
                        args+=(
                            'google-cloud-sdk'
                        )
                    elif _koopa_is_macos
                    then
                        args+=(
                            'defaults'
                        )
                    fi
                    ;;
                *)
                    ;;
            esac
            ;;
        '3')
            [[ "${COMP_WORDS[COMP_CWORD-3]}" == 'koopa' ]] || return 0
            if [[ "${COMP_WORDS[COMP_CWORD-2]}" == 'app' ]] && \
                [[ "${COMP_WORDS[COMP_CWORD-1]}" == 'conda' ]]
            then
                args=('create-env' 'remove-env')
            fi
            ;;
    esac
    # Quoting inside the array doesn't work for Bash, but does for Zsh.
    COMPREPLY=($(compgen -W "${args[*]}" -- "${COMP_WORDS[COMP_CWORD]}"))
    return 0
}

complete -F _koopa_complete koopa
