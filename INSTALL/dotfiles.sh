dotfile() {
    file="$1"
    rm -f ".${file}"
    ln -s ".dotfiles/${file}" ".${file}"
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

    # Directories
    dotfile vim

    case "$KOOPA_HOST_NAME" in
                azure) dotfile Renviron-azure;;
                darwin) dotfile Renviron-darwin;;
            harvard-o2) dotfile Renviron-harvard-o2;;
        harvard-odyssey) dotfile Renviron-harvard-odyssey;;
                    *) ;;
    esac
)

