#/bin/sh

# Mike-specific dot files.
# Modified 2019-06-17.

private_dir="${KOOPA_CONFIG_DIR}/dotfiles-private"
if [ ! -d "$private_dir" ]
then
    git clone git@github.com:mjsteinbaugh/dotfiles-private.git "$private_dir"
fi
unset -v private_dir

dotfile -f forward

if [ "$os" = "darwin" ]
then
    dotfile -f os/darwin/gitconfig
else
    dotfile -f gitconfig
fi

dotfile --private Rsecrets
dotfile --private secrets
dotfile --private travis
