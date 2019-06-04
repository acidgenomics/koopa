#!/usr/bin/env bash
set -Eeuxo pipefail

dotfile() {
    dot_dir="${HOME}/.dotfiles"
    # Use `-f` here because we're symlinking.
    [ ! -f "$dot_dir" ] && echo "${dot_dir} missing." && exit 1
    
    source_file="$1"
    source_file="${dot_dir}/${source_file}"
    [ ! -f "$source_file" && echo "${source_file} missing." && exit 1

    dest_file="${2:-}"
    if [[ -z "$dest_file" ]]
    then
        dest_file="$source_file"
    fi
    dest_file="${HOME}/.${dest_file}"
    
    rm -f "$dest_file"
    ln -s "$source_file" "$dest_file"
}

(
    cd ~

    rm -rf .dotfiles
    ln -s koopa/dotfiles .dotfiles

    # Files
    dotfile bashrc
    dotfile bash_profile
    dotfile condarc
    dotfile gitconfig
    dotfile gitignore_global
    dotfile Rprofile
    dotfile spacemacs
    dotfile tmux.conf
    dotfile vimrc
    dotfile zshrc

    # Directories
    dotfile vim

    case "$KOOPA_HOST_NAME" in
                  azure) dotfile Renviron-azure Renviron;;
                 darwin) dotfile Renviron-darwin Renviron;;
             harvard-o2) dotfile Renviron-harvard-o2 Renviron;;
        harvard-odyssey) dotfile Renviron-harvard-odyssey Renviron;;
                      *) ;;
    esac
)

