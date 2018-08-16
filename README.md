# koopa

[![Build Status](https://travis-ci.org/steinbaugh/koopa.svg?branch=master)](https://travis-ci.org/steinbaugh/koopa)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

High-performance computing shell bootloader for bioinformatics.


## Installation

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```bash
git clone https://github.com/steinbaugh/koopa.git ~/koopa
```

Add these lines to your `.bashrc` file:

```bash
# koopa shell
# https://github.com/steinbaugh/koopa
if [[ -n "$PS1" ]] && [[ -f ~/koopa/koopa.sh ]]; then
    . ~/koopa/koopa.sh
fi
```

To also load koopa on a login node, we recommend symlinking your `.bashrc` file to `.bash_profile`:

```bash
ln -s ~/.bashrc ~/.bash_profile
```


## Interactive session

To launch an interactive session, simply run:

```bash
koopa interactive -c <cores> -m <memory> -t <time>
```

For example, here's how to start an interactive session for 6 hours using 2 cores and 8 GB of RAM per core, on an HPC using the [slurm] scheduler:

```bash
koopa interactive -c 2 -m 8 -t 0-06:00
```


[slurm]: https://slurm.schedmd.com
