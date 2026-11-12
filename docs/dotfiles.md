# Dotfiles

Koopa's [dotfiles](https://github.com/acidgenomics/dotfiles) configure the current
user's shell and developer environment. They are managed with
[chezmoi](https://www.chezmoi.io), which renders configuration templates into your
home directory using machine-specific settings.

The configuration includes shell startup and koopa activation, plus settings for
terminal emulators, editors, shells, and command-line tools. It also provides
dark/light color themes for supported applications. Optional work or private
configuration trees are applied after the public dotfiles when present.

Install the dotfiles and apply them to your environment with:

```sh
koopa install dotfiles
koopa configure user dotfiles
```

`koopa configure user dotfiles` applies the managed configuration and may update or
remove files in your home directory. Review the changes before applying if you have
existing personal configuration in those locations. Koopa does not apply dotfiles
automatically during `koopa update`; run the configure command when you are ready to
write them.
