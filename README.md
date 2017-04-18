# seqcloud

[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Connect to your high-performance computing (HPC) cluster and clone our git repository.

```{bash}
git clone https://github.com/steinbaugh/seqcloud.git ~/seqcloud
```


## [HMS Orchestra](https://wiki.med.harvard.edu/Orchestra/WebHome) setup

### `.bash_profile` file

This will automatically boot an interactive session upon login.

```{bash}
bsub -Is -q interactive bash
```

### `.bashrc` file

This will automatically load `seqcloud` in the interactive session.

```{bash}
. ~/seqcloud/seqcloud.sh
```

We also advise restricting world access by default for enhanced security.

```{bash}
umask 007
```
