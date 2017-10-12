# seqcloud

[![Build Status](https://travis-ci.org/steinbaugh/seqcloud.svg?branch=master)](https://travis-ci.org/steinbaugh/seqcloud)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## Bash shell setup

```{bash}
nano ~/.bashrc
```

Add this line to your `.bashrc` file:

```
. ~/seqcloud/seqcloud.sh
```

To also load seqcloud on a login node, we recommend symlinking your `.bashrc` file to `.bash_profile`:

```{bash}
ln -s ~/.bashrc ~/.bash_profile
```

To launch and interactive session, simply run:

```{bash}
seqcloud interactive <cores> <ram_gb>
```
