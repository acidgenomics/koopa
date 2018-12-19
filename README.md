# koopa 🐢

[![Build Status](https://travis-ci.org/steinbaugh/koopa.svg?branch=master)](https://travis-ci.org/steinbaugh/koopa)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Shell bootloader for bioinformatics.

## Requirements

- Linux or macOS. Windows isn't supported.
- [Bash][] >= v4.
- [Python][]. Both v2.7 and v3 are supported.

[Zsh][] support may be added in a future update. I'm looking into it.

## Installation

First, clone the repository:

```bash
git clone https://github.com/steinbaugh/koopa.git ~/koopa
```

Second, add these lines to `~/.bash_profile`:

```bash
# koopa shell
# https://github.com/steinbaugh/koopa
source ~/koopa/bin/koopa activate
```

Koopa should now activate at login.

To obtain information about the working environment, run `koopa info`.

[Bash]: https://www.gnu.org/software/bash/
[Python]: https://www.python.org/
[Zsh]: https://www.zsh.org/
