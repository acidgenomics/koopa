#!/usr/bin/env bash
set -Eeuxo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"



# Initialize submodules                                                     {{{1
# ==============================================================================
(
    # shellcheck source=/dev/null
    cd "$script_dir"
    git submodule init
    git submodule update
)

(
    # shellcheck source=/dev/null
    cd "${script_dir}/dotfiles"
    git submodule init
    git submodule update
)



# Install programs                                                          {{{1
# ==============================================================================

# shellcheck source=/dev/null
. "${script_dir}/bin/install-spacemacs"



# Dot file symlinks                                                         {{{1
# ==============================================================================

dotfile() {
    # Don't use the full path here, it makes the symlinks more flexible.
    dot_dir=".dotfiles"
    [[ ! -L "$dot_dir" || ! -d "$dot_dir" ]] && \
        echo "${dot_dir} not configured correctly." && \
        exit 1
    
    source_file="$1"
    dest_file="${2:-}"
    if [[ -z "$dest_file" ]]
    then
        dest_file="$source_file"
    fi
    
    source_file="${dot_dir}/${source_file}"
    [[ ! -f "$source_file" && ! -d "$source_file" ]] \
        && echo "${source_file} missing." && \
        exit 1

    dest_file="${HOME}/.${dest_file}"
    
    rm -f "$dest_file"
    ln -s "$source_file" "$dest_file"
}

(
    cd ~

    rm -rf .dotfiles
    ln -s koopa/dotfiles .dotfiles
    
    case "$KOOPA_HOST_NAME" in
        azure) dotfile shrc-azure shrc ;;
            *) dotfile shrc ;;
    esac
    
    rm -f .bashrc .bash_profile .kshrc .zshrc
    ln -s .shrc .bashrc
    ln -s .shrc .kshrc
    ln -s .shrc .zshrc
    ln -s .bashrc .bash_profile

    dotfile condarc
    dotfile gitconfig
    dotfile gitignore_global
    dotfile Rprofile
    dotfile spacemacs
    dotfile tmux.conf
    dotfile vim
    dotfile vimrc

    case "$KOOPA_HOST_NAME" in
                 darwin) dotfile Renviron-darwin Renviron ;;
             harvard-o2) dotfile Renviron-harvard-o2 Renviron ;;
        harvard-odyssey) dotfile Renviron-harvard-odyssey Renviron ;;
                      *) dotfile Renviron ;;
    esac

)



# Update                                                                    {{{1
# ==============================================================================

# shellcheck source=/dev/null
. "${script_dir}/UPDATE.sh"



# vim: fdm=marker
