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

## Configuration

Koopa provides automatic configuration and `PATH` variable handling for a number of popular bioinformatics tools. When configuring manually, ensure that variables are defined before running `koopa activate`.

### Aspera Connect

Fully automatic when installed at `~/.aspera/`.
Otherwise, can define manually using the `ASPERA_EXE` variable.

```bash
export ASPERA_EXE="${HOME}/.aspera/connect/bin/asperaconnect"
```

### bcbio

Fully automatic for the Harvard O2 and Odyssey high-performance computing clusters.
Otherwise, can define manually using the `BCBIO_EXE` variable.

```
export BCBIO_EXE="/n/app/bcbio/tools/bin/bcbio_nextgen.py"
```

### conda

Fully automatic when conda is installed at any of these locations (note priority):

- `~/anaconda3/`
- `~/miniconda3/`
- `/usr/local/bin/anaconda3/`
- `/usr/local/bin/miniconda3/`

Oherwise, can define manually using the `CONDA_EXE` variable.

```bash
export CONDA_EXE="${HOME}/anaconda3/bin/conda"
```

Koopa also supports automatic loading of a default environment other than `base`.
Simply set the `CONDA_DEFAULT_ENV` variable to your desired environment name.

```bash
export CONDA_DEFAULT_ENV="tensorflow"
```

### SSH key

On Linux, koopa will launch `ssh-agent` and attempt to import the default SSH key at `~/.ssh/id_rsa`, if the key file exists. A different default key can be defined manually using the `SSH_KEY` variable.

```
export SSH_KEY="${HOME}/.ssh/id_rsa"
```

On macOS, instead we recommend adding these lines to `~/.ssh/config` to use the system keychain:

```
Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    UseKeychain yes
```

### PGP key

Automatic PGP key support will be added in a future update.
