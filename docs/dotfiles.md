# Dotfiles

Configure the current user's environment using our
[dotfiles](https://github.com/acidgenomics/dotfiles) repo, which is currently powered
by [chezmoi](https://www.chezmoi.io). Alternatively, run `koopa update user`.
Automatic writing of dotfiles is a destructive action, so this is not enabled by
default in `koopa update`.

```sh
koopa install dotfiles
koopa configure user dotfiles
```
