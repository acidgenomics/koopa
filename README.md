# seqcloud

[![Build Status](https://travis-ci.org/seqcloud/seqcloud.svg?branch=master)](https://travis-ci.org/seqcloud/seqcloud)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

High-performance computing shell bootloader for bioinformatics.


## Installation

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```bash
git clone https://github.com/seqcloud/seqcloud.git ~/seqcloud
```

Add these lines to your `.bashrc` file:

```bash
# seqcloud
if [[ -f ~/seqcloud/seqcloud.sh ]]; then
    . ~/seqcloud/seqcloud.sh
fi
```

To also load seqcloud on a login node, we recommend symlinking your `.bashrc` file to `.bash_profile`:

```bash
ln -s ~/.bashrc ~/.bash_profile
```


## Interactive queue

To launch an interactive queue, simply run:

```bash
seqcloud interactive -c <cores> -m <mem_gb>
```
