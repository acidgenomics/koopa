# koopa 🐢

![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)

Shell bootloader for data science.

## Requirements

- Linux or macOS.
  On Windows, consider using [Ubuntu for WSL](https://ubuntu.com/wsl/).
- [POSIX](https://en.wikipedia.org/wiki/POSIX)-compliant login shell
  ([bash](https://www.gnu.org/software/bash/),
  [zsh](https://www.zsh.org/),
  [dash](https://git.kernel.org/pub/scm/utils/dash/dash.git),
  [ksh93](http://www.kornshell.com/)),
  [fish](https://fishshell.com/),
  [elvish](https://elv.sh/),
  [nushell](https://www.nushell.sh/),
  or [powershell](https://learn.microsoft.com/en-us/powershell/).
- [Python](https://www.python.org/) 3.12+, which will be bootstrap installed
  into `~/.local/share/koopa-bootstrap` automatically when necessary.
- Core utilities: `curl`, `git`, `grep`, `mkdir`, `mktemp`, `rm`, `sed`, `tar`.

## Installation

```sh
sh -c "$(curl -LSs https://koopa.acidgenomics.com/install)"
```

Refer to the [koopa website](https://koopa.acidgenomics.com/) for full
installation and usage details.
