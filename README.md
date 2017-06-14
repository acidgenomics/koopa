# seqcloud

[![Build Status](https://travis-ci.org/steinbaugh/seqcloud.svg?branch=master)](https://travis-ci.org/steinbaugh/seqcloud)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## [HMS Orchestra](https://wiki.med.harvard.edu/Orchestra/WebHome) setup

### `.bash_profile` file

This will automatically boot an interactive session upon login.

```{bash}
# HMS Orchestra bash login shell settings
# (c) 2017 seqcloud (http://seq.cloud/)
# Interactive settings must be saved in `~/.bashrc` instead of here.
alias i="bsub -Is -q interactive bash"
alias e="exit"
i
```

### `.bashrc` file

This will automatically load `seqcloud` in the interactive session.

```{bash}
# Interactive bash non-login shell settings
# (c) 2017 seqcloud (http://seq.cloud/)
. ~/seqcloud/seqcloud.sh
```
