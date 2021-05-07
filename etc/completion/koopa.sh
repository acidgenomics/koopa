#!/usr/bin/env bash
# shellcheck disable=SC2207

# """
# Bash/Zsh TAB completion.
# Updated 2021-05-07.
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
            'check-system'
            'get-version'
            'header'
            'info'
            'install'
            'list'
            'prefix'
            'test'
            'uninstall'
            'update'
        )
        if _koopa_is_linux
        then
            args+=(
                'delete-cache'
            )
        fi
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
                    'homebrew-packages'
                    'htop'
                    'julia'
                    'libevent'
                    'libtool'
                    'lua'
                    'luarocks'
                    'make'
                    'miniconda'
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
                    'spacemacs'
                    'spacevim'
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
                    'log'
                    'pull'
                )
                ;;
            uninstall)
                args=(
                    'dotfiles'
                    'homebrew'
                    'koopa'
                    'spacevim'
                )
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
