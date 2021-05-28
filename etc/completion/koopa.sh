#!/usr/bin/env bash
# shellcheck disable=SC2207

# """
# Bash/Zsh TAB completion.
# Updated 2021-05-20.
#
# Keep all of these commands in a single file.
# Sourcing multiple scripts doesn't work reliably.
#
# Multi-level bash completion:
# - https://stackoverflow.com/questions/17879322/
# - https://stackoverflow.com/questions/5302650/
# """

_koopa_complete() { # {{{1
    local args cur prev
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    if [[ "$COMP_CWORD" -eq 1 ]]
    then
        args=(
            '--help'
            '--version'
            'app'
            'header'
            'install'
            'list'
            'system'
            'test'
            'uninstall'
            'update'
        )
        # Quoting inside the array doesn't work on Bash.
        COMPREPLY=($(compgen -W "${args[*]}" -- "$cur"))
    elif [[ "$COMP_CWORD" -eq 2 ]]
    then
        case "$prev" in
            app)
                args=(
                    'clean'
                    'list'
                    'link'
                    'unlink'
                )
                ;;
            header)
                args=(
                    'bash'
                    'posix'
                    'r'
                    'zsh'
                )
                ;;
            install)
                args=(
                    'anaconda'
                    'autoconf'
                    'automake'
                    'bash'
                    'binutils'
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
                    'homebrew-packages'  # FIXME Remove?
                    'htop'
                    'julia'
                    'libevent'
                    'libtool'
                    'lua'
                    'luarocks'
                    'make'
                    'miniconda'  # FIXME Rename to just conda...
                    'ncurses'
                    'neofetch'
                    'neovim'
                    'openjdk'
                    'openssh'
                    'openssl'
                    'parallel'
                    'password-store'
                    'patch'
                    'perl'
                    'perl-packages'
                    'perlbrew'
                    'perlbrew-perl'
                    'pkg-config'
                    'proj'
                    'pyenv'
                    'python'
                    'python-packages'
                    'r'
                    'r-cmd-check'
                    'r-devel'
                    'r-koopa'
                    'r-packages'
                    'rbenv'
                    'rbenv-ruby'
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
                    'spacemacs'  # FIXME Need to indicate user here?
                    'spacevim'  # FIXME Need to indicate user here?
                    'sqlite'
                    'subversion'
                    'taglib'
                    'tar'
                    'tex-packages'
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
                        'bcbio'
                        'bcl2fastq'
                        'cellranger'
                        'cloudbiolinux'
                        'docker-credential-pass'
                        'julia'
                        'lmod'
                        'rstudio-server'
                        'shiny-server'
                    )
                fi
                if _koopa_is_macos
                then
                    args+=(
                        'homebrew-little-snitch'
                        'python-framework'
                        'r-cran-gfortran'
                        'r-framework'  # FIXME
                        'xcode-clt'
                    )
                fi
                ;;
            list)
                args=(
                    'app-versions'
                    'dotfiles'
                    'path-priority'
                )
                ;;
            system)
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
                    'pull'
                    'roff'
                    'set-permissions'
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
            uninstall)
                args=(
                    'anaconda'  # FIXME
                    'autoconf'  # FIXME
                    'automake'  # FIXME
                    'bash'  # FIXME
                    'binutils'  # FIXME
                    'cmake'  # FIXME
                    'conda'  # FIXME
                    'coreutils'  # FIXME
                    'cpufetch'  # FIXME
                    'curl'  # FIXME
                    'doom-emacs'  # FIXME
                    'dotfiles'
                    'emacs'  # FIXME
                    'ensembl-perl-api'  # FIXME
                    'findutils'  # FIXME
                    'fish'  # FIXME
                    'fzf'  # FIXME
                    'gawk'  # FIXME
                    'gcc'  # FIXME
                    'gdal'  # FIXME
                    'geos'  # FIXME
                    'git'  # FIXME
                    'gnupg'  # FIXME
                    'go'  # FIXME
                    'grep'  # FIXME
                    'groff'  # FIXME
                    'gsl'  # FIXME
                    'haskell-stack'  # FIXME
                    'hdf5'  # FIXME
                    'homebrew'
                    'htop'  # FIXME
                    'julia'  # FIXME
                    'koopa'
                    'libevent'  # FIXME
                    'libtool'  # FIXME
                    'lua'  # FIXME
                    'luarocks'  # FIXME
                    'make'
                    'miniconda'  # FIXME Rename to just conda...
                    'ncurses'  # FIXME
                    'neofetch'  # FIXME
                    'neovim'  # FIXME
                    'openjdk'  # FIXME
                    'openssh'  # FIXME
                    'openssl'  # FIXME
                    'parallel'  # FIXME
                    'password-store'  # FIXME
                    'patch'  # FIXME
                    'perl'  # FIXME
                    'perl-packages'  # FIXME prompt about this
                    'perlbrew'  # FIXME
                    'pkg-config'  # FIXME
                    'proj'  # FIXME
                    'pyenv'  # FIXME
                    'python'  # FIXME
                    'python-packages'  # FIXME prompt about this
                    'r'  # FIXME
                    'r-cmd-check'  # FIXME
                    'r-devel'  # FIXME
                    'r-koopa'  # FIXME
                    'r-packages'  # FIXME prompt about this
                    'rbenv'  # FIXME
                    'rbenv-ruby'  # FIXME
                    'rmate'  # FIXME
                    'rsync'  # FIXME
                    'ruby'  # FIXME
                    'ruby-packages'  # FIXME
                    'rust'  # FIXME
                    'rust-packages'  # FIXME prompt about this
                    'sed'  # FIXME
                    'shellcheck'  # FIXME
                    'shunit2'  # FIXME
                    'singularity'  # FIXME
                    'spacemacs'  # FIXME
                    'spacevim'
                    'sqlite'  # FIXME
                    'subversion'  # FIXME
                    'taglib'  # FIXME
                    'tar'  # FIXME
                    'tex-packages'  # FIXME
                    'texinfo'  # FIXME
                    'the-silver-searcher'  # FIXME
                    'tmux'  # FIXME
                    'udunits'  # FIXME
                    'vim'  # FIXME
                    'wget'  # FIXME
                    'zsh'  # FIXME
                )
                if _koopa_is_linux
                then
                    args+=(
                        'aspera-connect'  # FIXME
                        'aws-cli'  # FIXME
                        'bcbio'  # FIXME
                        'bcl2fastq'  # FIXME
                        'cellranger'  # FIXME
                        'cloudbiolinux'  # FIXME
                        'docker-credential-pass'  # FIXME
                        'julia'  # FIXME
                        'lmod'  # FIXME prompt about this?
                        'rstudio-server'  # FIXME
                        'shiny-server'  # FIXME
                    )
                fi
                if _koopa_is_macos
                then
                    args+=(
                        'homebrew-little-snitch'  # FIXME
                        'python-framework'  # FIXME
                        'r-cran-gfortran'
                        'r-framework'  # FIXME
                        'xcode-clt'  # FIXME
                    )
                fi
                ;;
            update)
                args=(
                    # koopa:
                    'system'
                    'user'
                    # packages:
                    'dotfiles'
                    'emacs'
                    'google-cloud-sdk'
                    'homebrew'
                    'pyenv'
                    'python-packages'
                    'r-packages'
                    'rbenv'
                    'ruby-packages'
                    'rust'
                    'rust-packages'
                    'tex'
                )
                ;;
            *)
                ;;
        esac
        # Quoting inside the array doesn't work on Bash.
        COMPREPLY=($(compgen -W "${args[*]}" -- "$cur"))
    fi
    return 0
}

# @seealso
# - https://github.com/scop/bash-completion/
# - https://www.gnu.org/software/bash/manual/html_node/
#     A-Programmable-Completion-Example.html


complete -F _koopa_complete koopa
