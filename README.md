# koopa 🐢

[![Travis CI build status](https://travis-ci.com/acidgenomics/koopa.svg?branch=master)](https://travis-ci.com/acidgenomics/koopa)
[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Shell bootloader for bioinformatics.

Refer to the [koopa][] website for usage details.

## Requirements

- Linux or macOS.
- [POSIX][]-compliant shell: [bash][] or [zsh][].

Dependencies:

- [Bash][] >= 4.
- [Python][] >= 3.7.
- [R][] >= 3.6.

Tested on:

- macOS Mojave
- Ubuntu 18 LTS
- Debian Buster
- RHEL 8 / CentOS 8
- RHEL 7 / CentOS 7
- Amazon Linux 2


## Installation

### Single user

Install into `~/.local/share/koopa`. This follows the recommended [XDG base directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

```sh
curl -sSL "https://raw.githubusercontent.com/acidgenomics/koopa/master/install" | bash
```

Add these lines to your shell configuration file:

```sh
# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"
. "${XDG_DATA_HOME}/koopa/activate"
```

Not sure where to source `activate` in your configuration? Here are some general
recommendations, in order of priority for each shell. These can differ depending
on the operating system, so refer to your shell documentation for details.

- [bash][]: `.bash_profile`, `.bashrc`.
- [zsh][]: `.zshrc`, `.zprofile`.

### Shared for all users

Install into `/usr/local/koopa`. This requires sudo (i.e. administrator) permissions.

```sh
curl -sSL "https://raw.githubusercontent.com/acidgenomics/koopa/master/install" | bash -s -- --shared
```

This will add a shared profile configuration file at `/etc/profile.d/koopa.sh` for supported Linux distros, but not macOS.

If you're going to install any programs using the cellar scripts, also ensure the permissions for `/usr/local/` are group writable. The installer attempts to fix this automatically, if necessary.

### Check installation

Restart the shell. Koopa should now activate automatically at login. You can
verify this with `command -v koopa`. Next, check your environment dependencies
with `koopa check`. To obtain information about the working environment, run
`koopa info`.

[bash]: https://www.gnu.org/software/bash/  "Bourne Again SHell"
[dash]: https://wiki.archlinux.org/index.php/Dash  "Debian Almquist SHell"
[fish]: https://fishshell.com/  "Friendly Interactive SHell"
[koopa]: https://koopa.acidgenomics.com/
[ksh]: http://www.kornshell.com/  "KornSHell"
[posix]: https://en.wikipedia.org/wiki/POSIX  "Portable Operating System Interface"
[python]: https://www.python.org/
[r]: https://www.r-project.org/
[tcsh]: https://en.wikipedia.org/wiki/Tcsh  "TENEX C Shell"
[zsh]: https://www.zsh.org/  "Z SHell"
