# koopa 🐢

[![Travis CI build status](https://travis-ci.com/acidgenomics/koopa.svg?branch=master)](https://travis-ci.com/acidgenomics/koopa)
[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Shell bootloader for bioinformatics.

Refer to the [koopa website][] for usage details.

## Installation

These [POSIX][]-compliant shells are supported: [bash][], [zsh][].

[dash][], [ksh][], and [tcsh][] shells aren't supported.

Support for the non-POSIX [fish][] shell may be added in a future release, but
is currently unsupported.

Requirements:

- Linux or macOS. Windows isn't supported.
- [Bash][] >= 4. Required even when using a different shell.
- [Python][] >= 3.7.
- [R][] >= 3.6.

Tested on:

- macOS Mojave
- Ubuntu 18 LTS
- Debian Buster
- RHEL 8 / CentOS 8
- RHEL 7 / CentOS 7
- Amazon Linux 2

### Shared user installation

Installs to `/usr/local/koopa`. Requires sudo permissions.


```sh
curl -sSL "https://raw.githubusercontent.com/acidgenomics/koopa/master/install" | bash -s -- --shared
```

This will add a shared profile configuration file at `/etc/profile.d/koopa.sh` for supported Linux distros, but not macOS.

If you're going to install any programs using the cellar scripts, also ensure the permissions for `/usr/local/` are group writable. The installer attempts to fix this automatically, if necessary.

### Single user installation

Installs to `~/.local/share/koopa`, following the recommended [XDG base directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

```sh
curl -sSL "https://raw.githubusercontent.com/acidgenomics/koopa/master/install" | bash
```

Add these lines to your shell configuration file.

```sh
# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
. "${XDG_DATA_HOME}/koopa/activate"
```

### Check installation

Restart the shell. Koopa should now activate automatically at login. You can
verify this with `command -v koopa`. Next, check your environment dependencies
with `koopa check`. To obtain information about the working environment, run
`koopa info`.

## Troubleshooting

### Shell configuration file

Not sure where to source `activate` in your configuration? Here are some general
recommendations, in order of priority for each shell. These can differ depending
on the operating system, so refer to your shell documentation for details.

- [bash][]: `.bash_profile`, `.bashrc`.
- [zsh][]: `.zshrc`, `.zprofile`.



[aspera connect]: https://downloads.asperasoft.com/connect2/
[bash]: https://www.gnu.org/software/bash/  "Bourne Again SHell"
[bcbio]: https://bcbio-nextgen.readthedocs.io/
[conda]: https://conda.io/
[dash]: https://wiki.archlinux.org/index.php/Dash  "Debian Almquist SHell"
[dotfiles]: https://github.com/mjsteinbaugh/dotfiles/
[fish]: https://fishshell.com/  "Friendly Interactive SHell"
[git]: https://git-scm.com/
[ksh]: http://www.kornshell.com/  "KornSHell"
[pgp]: https://www.openpgp.org/
[posix]: https://en.wikipedia.org/wiki/POSIX  "Portable Operating System Interface"
[python]: https://www.python.org/
[r]: https://www.r-project.org/
[ssh]: https://en.wikipedia.org/wiki/Secure_Shell
[tcsh]: https://en.wikipedia.org/wiki/Tcsh  "TENEX C Shell"
[zsh]: https://www.zsh.org/  "Z SHell"
