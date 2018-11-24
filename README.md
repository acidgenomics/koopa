# koopa 🐢

[![Build Status](https://travis-ci.org/steinbaugh/koopa.svg?branch=master)](https://travis-ci.org/steinbaugh/koopa)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Shell bootloader for bioinformatics.

## Installation

Bash shell running on either Linux or macOS is currently supported.

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

Koopa should now activate at login. To obtain information on the current working enviroment, simply run `koopa info`.

## High-performance computing (HPC) environment

Since workload managers (e.g. [Slurm][], [LSF][]) can spawn non-interactive login shells for new jobs, we recommend additionally symlinking `~/.bashrc` to `~/.bash_profile`. For non-interactive login shells, koopa doesn't attempt to print any messages, so the shell remains clean.

[LSF]: https://www.ibm.com/support/knowledgecenter/en/SSETD4/product_welcome_platform_lsf.html
[Slurm]: https://slurm.schedmd.com
