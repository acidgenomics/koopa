# Activation

Here are some general recommendations for each shell. These can differ depending on
the operating system, so refer to your shell documentation for details.

- bash: `.bashrc`, `.bash_profile` -- source `activate.sh`
- dash: `.profile` -- source `activate.sh`
- ksh93: `.profile` -- source `activate.sh`
- zsh: `.zshrc` -- source `activate.sh`
- fish: `~/.config/fish/config.fish` -- source `activate.fish`
- elvish: `~/.config/elvish/rc.elv` -- source `activate.elv`
- nushell: `~/.config/nushell/env.nu` + `~/.config/nushell/config.nu` -- source
  `activate.nu`
- powershell: `$PROFILE` -- source `activate.ps1`
- csh/tcsh: `.cshrc` / `.tcshrc` -- source `activate.csh` (minimal: `PATH` and
  environment variables only)

Here is an example using `activate.sh` for POSIX shell configuration:

```sh
# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
if [ -f "${XDG_DATA_HOME}/koopa/activate.sh" ]
then
    . "${XDG_DATA_HOME}/koopa/activate.sh"
fi
```

Restart the shell. Koopa should now activate automatically at login. You can verify
this with `command -v koopa`.

Automatic shell configuration is enabled by our `dotfiles` management, documented in
[Dotfiles](dotfiles.md).

User-specific activation is not required for a shared koopa installation on Linux,
which writes a configuration file into `/etc/profile.d/zzz-koopa.sh`.

On a host where the login shell can't be changed (common on shared HPC or Slurm
login nodes), koopa's `.profile` hands an interactive `dash`/`ksh93` session off to
Bash automatically, when Bash is on `PATH`. This runs before `activate.sh` is
sourced, so the full Bash activation (completions, prompt, and other Bash/Zsh-only
configuration) still applies. Set `KOOPA_NO_SHELL_UPGRADE=1` to opt out and stay on
the POSIX shell.
