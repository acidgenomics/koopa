# koopa

![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)
![License: Apache-2.0](https://img.shields.io/github/license/acidgenomics/koopa?cacheSeconds=86400)

![koopa terminal session](https://koopa.acidgenomics.com/_static/screenshot-light.png)

Shell bootloader for data science.

Source code is available on [GitHub](https://github.com/acidgenomics/koopa).

## Installation

```sh
sh -c "$(curl -LSs https://koopa.acidgenomics.com/install)"
```

See the [installation guide](https://koopa.acidgenomics.com/installation.html) for
the full install flow, or jump to the [CLI reference](https://koopa.acidgenomics.com/reference/index.html)
for every `koopa` command.

Guides: [Applications](https://koopa.acidgenomics.com/apps.html),
[Activation](https://koopa.acidgenomics.com/activation.html),
[Dotfiles](https://koopa.acidgenomics.com/dotfiles.html), and
[Troubleshooting](https://koopa.acidgenomics.com/troubleshooting.html).

## Requirements

- Linux (x86_64 or arm64) or macOS (Apple Silicon / arm64 only).
  Intel Macs (x86_64) are no longer supported.
  On Windows, consider using [Ubuntu for WSL](https://ubuntu.com/wsl/).
  [BusyBox](https://busybox.net/) is not supported.
- [POSIX](https://en.wikipedia.org/wiki/POSIX)-compliant login shell
  ([bash](https://www.gnu.org/software/bash/),
  [zsh](https://www.zsh.org/),
  [dash](https://git.kernel.org/pub/scm/utils/dash/dash.git),
  [ksh93](http://www.kornshell.com/)),
  [fish](https://fishshell.com/),
  [elvish](https://elv.sh/),
  [nushell](https://www.nushell.sh/),
  or [PowerShell](https://learn.microsoft.com/en-us/powershell/).
  csh and tcsh have minimal support (`PATH` and environment variables only).
- [Python](https://www.python.org/) 3.14, which will be bootstrap installed into
  `~/.local/share/koopa-bootstrap` automatically when necessary.
- Core utilities: `curl`, `git`, `grep`, `mkdir`, `mktemp`, `rm`, `sed`, `tar`.
- macOS requires Xcode Command Line Tools.

## License

© 2016-pres. [Acid Genomics](https://acidgenomics.com/) LLC · Apache 2.0 ([LICENSE](LICENSE)).
