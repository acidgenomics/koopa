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
                # NOTE Consider indicating support of these arguments:
                # '--no-link', '--reinstall', and '--version'.
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
                    'htop'
                    'julia'
                    'libevent'
                    'libtool'
                    'lua'
                    'luarocks'
                    'make'
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
                    'prelude-emacs'
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
                        'google-cloud-sdk'
                        'julia'
                        'lmod'
                        'rstudio-server'
                        'rstudio-workbench'
                        'shiny-server'
                    )
                fi
                if _koopa_is_macos
                then
                    args+=(
                        'homebrew-little-snitch'
                        'python-framework'
                        'r-cran-gfortran'
                        'r-framework'
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
                    'doom-emacs'  # FIXME
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
                    'htop'
                    'julia'
                    'koopa'
                    'libevent'  # FIXME
                    'libtool'  # FIXME
                    'lua'  # FIXME
                    'luarocks'  # FIXME
                    'make'
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
                    'prelude-emacs'  # FIXME
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
                        'google-cloud-sdk'
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
                    'doom-emacs'
                    'dotfiles'
                    'homebrew'
                    'prelude-emacs'  # FIXME
                    'pyenv'
                    'python-packages'
                    'r-packages'
                    'rbenv'
                    'ruby-packages'
                    'rust'
                    'rust-packages'
                    'spacemacs'
                    'spacevim'
                    'tex'
                )
                if _koopa_is_linux
                then
                    args+=(
                        'google-cloud-sdk'
                    )
                fi
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
