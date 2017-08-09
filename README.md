# seqcloud

[![Build Status](https://travis-ci.org/steinbaugh/seqcloud.svg?branch=master)](https://travis-ci.org/steinbaugh/seqcloud)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## [HMS RC](https://rc.hms.harvard.edu) setup

### `.bash_profile` file

This will automatically boot an interactive session upon login.

```{bash}
alias e="exit"
if [[ ! -z $SLURM_CONF ]]; then
    # O2
    alias i="srun -p interactive --pty --mem 8000 --time 1:00:00 /bin/bash"
elif [[ ! -z $LSF_ENVDIR ]]; then
    # Orchestra
    alias i="bsub -Is -W 1:00 -q interactive bash"
fi
i
```

### `.bashrc` file

This will automatically load `seqcloud` in the interactive session.

```{bash}
. ~/seqcloud/seqcloud.sh
```
