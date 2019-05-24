## koopa 0.3.4 (2019-05-24)

- Improved version dependency checks.
- Added new `check-versions` program, for additional version checks.
- Improved build scripts in `install/` to use `/tmp/` for temp files.
- New build scripts: bash, coreutils, gnupg, openssl, pass, r, rstudio-server,
  and zsh.
- Now using a shared `_init.sh` script for simpler build dependency checks.



## koopa 0.3.3 (2019-05-08)

- Renamed all exported scripts to no longer use file extensions. This makes
  transitioning any bash scripts to python easier, without breaking names.
- Reworked `shellcheck-recursive` to check for shell shebang, rather than
  relying on the file extension.
- Rewrote `download-fasta` and `download-gtf` in Python instead of Bash.



## koopa 0.3.2 (2019-04-18)

- Improved build scripts, and hardened some intended for RedHat Linux.
- Updated genome build information.
- Improved bcbio scripts and custom genome builds.
- New exported scripts: `ip-address.sh`, `vim-sort.sh`.
- Added script to build Python from source for RedHat.



## koopa 0.3.1 (2019-03-19)

- Updated to Ensembl release to 95.
- Updated GENCODE to release human 29 / mouse M20.
- Updated FlyBase to 2019_01.
- `git-pull-all.sh`: Added `git fetch` call.
- Improved build configuration scripts: emacs, git, gsl, openssl, tmux.
- Added bcbio system configuration files (bcbio_system.yaml).
- Improved default run template for bcbio RNA-seq.



## koopa 0.3.0 (2019-02-20)

This release overhauls the previous activation method. Refer to the README
for details on how to reconfigure your shell profile.

- Changed activation method to use `activate.sh` script at top of repo.
- Improved support for ksh and zsh shells. Added Travis CI checks.
- Added native support for zsh pure prompt, including async script. These files
  are saved in `zsh/fpath/`.
- Reorganized bcbio configuration scripts and templates.
- Completely overhauled system activation method. Additional shell
  configuration, including prompt string customization is now disabled by
  default. Refer to the installation instructions for details on how to enable
  this new optional `extra` mode.
- Reorganized installer scripts exported in `bin/` including conda scripts,
  `reset-permissions.sh`, `sudo-yum-update.sh`, etc.



## koopa 0.2.8 (2019-02-12)

- Migrated darwin (macOS)-specific scripts from bash repo to koopa.
- Migrated Harvard O2 and Harvard Odyssey HPC scripts here from bash repo.
- Added `rsync-azure-files.sh` script for working with Azure Shares (Samba).
- Added `autopad-samples.sh` script.
- Added `bash-strict-mode.sh` script.
- Added `md5sum.sh` script.
- Reorganized other scripts accessible via `bin/`.
- Reorganized activation and system scripts, in preparation for 0.3 release.



## koopa 0.2.7 (2019-02-04)

- Improved shellchecks on workflows.
- Split out some activation steps into separate scripts.



## koopa 0.2.6 (2019-01-23)

- Added back ".sh" extension for all exported scripts.
- Updated Travis CI configuration to use shellcheck.
- Reorganized and improved workflow scripts.



## koopa 0.2.5 (2019-01-07)

- Updated installation instructions to recommend cloning to `~/.koopa`.
- Conda now will only activate when `CONDA_DEFAULT_ENV` is set in environment.
  This improves handling in situations for user accounts where we don't want
  to activate conda in a shared environemnt (e.g. bioinfo account on Azure).



## koopa 0.1.1 (2018-09-05)

- Now exporting `KOOPA_VERSION` and `KOOPA_DATE` global variables.
- Updated installation instructions.
- Removed `/setup/` config files.
- Added support for automatic SSH key import, using `$SSH_KEY` variable.
- Removed "g*" aliases for GitHub commands (e.g. ga, gc, gd). Too confusing.
- Simplified the separator bar for koopa message, avoiding unicode.
- Renamed `bcl2fastq_indrop` script to `bcl2fastq_indrops`.
- Added some utility scripts from macOS bash repo:
      - delete_fs_cruft
      - git_pull_all
      - gzip_dir
      - install_tex
      - move_files_up_1_level
      - rename_from_csv
      - reset_permissions



## koopa 0.1.0 (2018-08-24)

- Initial stable release.
- Repo was previously named "seqcloud".
