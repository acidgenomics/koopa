#!/usr/bin/env bash
# shellcheck disable=SC2207

# """
# Bash/Zsh TAB completion.
# Updated 2021-06-11.
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
                    # These are unique to 'install'.
                    'homebrew-bundle'
                    'tex-packages'
                    # FIXME Need to share these with uninstall:
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
                    'pkg-config'
                    'prelude-emacs'
                    'proj'
                    'pyenv'
                    'python'
                    'python-packages'
                    'r'
                    'r-cmd-check'
                    'r-devel'
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
                # FIXME These are safe to share with 'uninstall'.
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
                # FIXME These are safe to share with 'uninstall'.
                if _koopa_is_macos
                then
                    args+=(
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
                    # These are unique to 'uninstall'.
                    'koopa'
                    # FIXME Need to share these with 'install'.
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
                    'pkg-config'
                    'prelude-emacs'
                    'proj'
                    'pyenv'
                    'python'
                    'python-packages'
                    'r'
                    'r-cmd-check'
                    'r-devel'
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
                # FIXME These are safe to share with 'install'.
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
                        'tex'  # FIXME
                    )
                fi
                # FIXME These are safe to share with 'install'.
                if _koopa_is_macos
                then
                    args+=(
                        'python-framework'
                        'r-cran-gfortran'
                        'r-framework'
                        'xcode-clt'
                    )
                fi
                ;;
            update)
                args=(
                    # koopa:
                    'system'
                    'user'
                    # packages:
                    'chemacs'
                    'doom-emacs'
                    'dotfiles'
                    'homebrew'
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
