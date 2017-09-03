# seqcloud

[![Build Status](https://travis-ci.org/steinbaugh/seqcloud.svg?branch=master)](https://travis-ci.org/steinbaugh/seqcloud)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## [HMS RC](https://rc.hms.harvard.edu) setup

### `.bashrc` file

This will automatically load `seqcloud` in an interactive session.

```{bash}
. ~/seqcloud/seqcloud.sh
```

### `.bash_profile` file

If you'd also like to load seqcloud on the login node, we recommend symlinking your `.bashrc` file to `bash_profile`:

```{bash}
ln -s ~/.bashrc ~/.bash_profile
```
