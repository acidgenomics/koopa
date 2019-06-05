#!/usr/bin/env bash
set -Eeuo pipefail

echo "Symlinking dot files."

dotfile() {
    dot_dir="${KOOPA_BASE_DIR}/dotfiles"
    [[ ! -d "$dot_dir" ]] && \
        echo "${dot_dir} missing." && \
        return 1
    
    source_file="$1"
    dest_file="${2:-}"
    if [[ -z "$dest_file" ]]
    then
        dest_file="$source_file"
    fi
    
    source_file="${dot_dir}/${source_file}"
    [[ ! -f "$source_file" && ! -d "$source_file" ]] \
        && echo "${source_file} missing." && \
        return 1

    dest_file="${HOME}/.${dest_file}"
    
    rm -f "$dest_file"
    ln -s "$source_file" "$dest_file"
}

(
    cd ~
    
    # Remove legacy symlinks.
    rm -rf .dotfiles
    
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
    dotfile doom.d
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

