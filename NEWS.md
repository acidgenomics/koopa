## koopa 0.5.7 (UNRELEASED)

### New scripts

- `install-rstudio-server-pro`: Added support for RStudio Server Pro
  installation on Fedora / RHEL.

### Minor changes

- Added 'download-' prefix to FASTA and GTF download scripts.
- Improved Emacs `emacs` and `spacemacs` configuration files inside the dotfiles
  repo, based on some issues seen in the Emacs GUI on macOS.

## koopa 0.5.6 (2019-09-18)

### New scripts

- `gencode-fasta` and `gencode-gtf` Python scripts for downloaded GENCODE
  genome annotations. Currently supports *Homo sapiens* and *Mus musculus*.
- (Azure) `link-msigdb`: Shared MSigDB file annotation utility.

### Minor changes

- Improved global activation of general exports, including `EDITOR`, which
  defines the default text editor. "vim" is recommended by default but "emacs"
  is also a good choice.

## koopa 0.5.5 (2019-09-09)

### Major changes

- Updater now checks for: oh-my-zsh, spacemacs symlinks in config directory.

### Minor changes

- Added install support for ChromHMM.
- Bug fix for directory creation in Python cellar script.
- ZSH configuration improvements.

## koopa 0.5.4 (2019-09-05)

### Minor changes

- Improved alias handling for zsh configuration.
- Added additional useful aliases and functions from Stephen Turner's oneliners
  guide for bioinformatics.
- Initial configuration support for autojump, currently limited to zsh. Will
  test and add bash support in a future update.

## koopa 0.5.3 (2019-08-28)

### Minor changes

- Improved zsh activation and oh-my-zsh configuration handling when koopa is
  active inside `/etc/profile.d/` on Linux (i.e. RHEL 7).

## koopa 0.5.2 (2019-08-18)

This release improves prompt consistency between zsh and bash.

### Minor changes

- Reworked prompt string configuration. Now automatically updates correctly
  when either a conda environment or Python virtual environment are loaded.
  Removed shell version and disk usage from the prompt.
- Updated zsh shell configuration to use our custom, more minimal koopa prompt
  instead of Pure prompt. This prompt is visually identical to our bash PS1.
- Reduced the number of available string returns from main `koopa` function.
  Instead, these are now called more consistently using internal prefixes.
  (e.g. `_koopa_cellar_prefix` instead of `koopa cellar-prefix)`.

## koopa 0.5.1 (2019-08-15)

### Minor changes

- Bug fixes for koopa activation inside a subshell (e.g. tmux or slurm queue).

## koopa 0.5.0 (2019-08-14)

### Major changes

- Koopa now attempts to source user configuration files prior to activation.
  This enables better passthrough of user-defined configuration variables.
- Simplified dotfiles configuration handling. Now need to install manually using
  `--dotfiles` flag or can use `install-dotfiles` script after installation.
- Fixed shell configuration when `EDITOR="emacs"`.

## koopa 0.4.6 (2019-08-01)

### New scripts

- `ftp-mirror`: Script that helps quickly mirror an FTP directory using wget.
- `install-rcheck`: Utility for quickly checking R packages.

### Minor changes

- Reworked the file paths of some dot files related to vim and zsh config.
- Improved `docker-run-image` workdir configuration.
- Improved shell checks, following shellcheck 0.7 release updates.
- Relaxed checks in Debian and Fedora headers when running as sudo user.

## koopa 0.4.5 (2019-07-29)

### Minor changes

- Improved detection and handling of unbound variables during installation and
  activation of koopa.

## koopa 0.4.4 (2019-07-28)

### New scripts

- `ffmepeg-alac-to-flac`, `ffmepeg-flac-to-alac`: Lossless audio conversion.
- `move-into-dated-dirs-by-filename`: Automatically move files containing a
  date (e.g. `2019-07-28-12-01-59.txt`) into dated subdirectories
  (e.g. `2019/07/28/`).
- `move-into-dated-dirs-by-timestamp`: Automatically move files into a dated
  subdirectory according to its timestamp.
- `sox-downsample`: Utilty script for easily downsampling high resolution audio.

#### Darwin (macOS)-specific

- `delete-adobe-bridge-cache`: Delete Adobe Bridge cache files.
- `dotfile-icloud`: Dot file utility for linking from iCloud, instead of our
  dotfiles git repo.
- `update-defaults`: Utility for setting recommended defaults. Modifies some
  finder settings, screen shots path, etc.

#### Debian-specific

- `install-git-lfs`: Utility script for installing Git LFS.

#### Fedora-specific

- Added additional packages to install via yum by default.
- `install-cellar-gdal`: New recipe required to install rgdal R package.
- `install-cellar-proj`: New recipe required to install rgdal R package.

### Major changes

- Installation will now clone private scripts and docker recipes. The activation
  script now knows to look for these and will add `bin/` directories to `PATH`.

### Minor changes

- Reworked linter engine to check for maximum of 80 characters per line.
- Improved internal update timestamp consistency across files.
- Improved shared Renviron and Rprofile site configuration files.

## koopa 0.4.3 (2019-07-25)

### New scripts

- `docker-run-image`: Useful utility script for booting a Docker image.
- `patch-bcbio`: Utility for patching bcbio development installation from
  GitHub codebase.
- `upgrade-bcbio`: Utilty for upgrading bcbio on a virtual machine.

## koopa 0.4.2 (2019-07-12)

### Minor changes

- Improved automatic XDG configuration in `~/.config/koopa`. Needed to update
  configuration of R symlink.

## koopa 0.4.1 (2019-07-11)

### Major changes

- Removed support for ksh. This shell does not support usage of `local`
  variables inside of functions, which are tremendously useful, and prevent
  accidental variable overwrites. Therefore, we're restricting support for
  bash and zsh at the moment.
- Improved Fedora install scripts to support RHEL 8. Also updated Docker install
  script to support RHEL 8.

### Minor changes

- Harden scripts to pass shellcheck.
- Switch back to using `-n` instead of `! -z` consistently for POSIX code.
  Double checking, this works correctly with latest version of ZSH.
- Sort arrays using `mapfile`, which is recommended by shellcheck.
- Improve shebang detection inside recursive shellcheck script.
- Added fixme/todo comments detection in linter script.
- Updated recommended program versions.
- Improved version checks inside `check.R` script.

### New programs

- Added `copy-bam-files` utility, which makes it easier to quickly set up an
  IGV session, which requires both `*.bam` and `*.bam.bai` files. Previously,
  this was named `cp-bam-files`.

## koopa 0.4.0 (2019-06-13)

This is the first release supported to work when installed at `/usr/local`.
This enables shared shell configuratino of all users, via configuration in
`/etc/profile` (or `/etc/profile.d/`) instead of relying on `.bash_profile`.

### Major changes

- koopa now checks for root and doesn't attempt to activate.
- Improved dotfile initialization, and no files are overwritten by default.
- Reworked `install` script, and added usage accessible via `--help`.
- Added `uninstall` utility script.
- Reworked activation scripts to support multi-user config.
- Reworked shared script header approach.
- Improved automatic `/etc/` configuration.

### Minor changes

- `KOOPA_HOME` path is always expanded, and symlinks are now resolved.
- Improved Travis CI testing approach.
- Reorganized workflow scripts.
- Split out functions into individual scripts.

## koopa 0.3.6 (2019-06-05)

### Major changes

- Improved update script.
- Install koopa using simply `install` instead of `INSTALL.sh`.
- Improved attempt at dotfiles auto-linking during `install` call.
- Improved OS-specific PATH exports.
- Switched to using `KOOPA_BUILD_PREFIX` and `KOOPA_TMP_DIR` variables for build scripts.

### New programs

- `sudo-install-amzn-base`: Recommended initial setup for Amazon Linux 2.
- `sudo-install-debian-base`: Recommended initial setup for Debian.
- `sudo-install-fedora-base`: Recommended initial setup for Fedora.
- `sudo-update-system` scripts for supported operating systems.
- `sudo-install-perl-rename`
- `sudo-install-shiny-server`

### Minor changes

- Removed attempt at automatic bcbio install detection for Azure. Consider
  linking current release as recommended in bcbio install instructions.
- Hardened some additional unbound variables detected in the activation scripts.
- Reworked bash and zsh activation steps. Namely, removed `init.sh` file.
- Disabled `set +x` for some scripts, which was used for testing.
- Renamed pre-flight check scripts.
- Hardened zsh setup scripts, using `[[` instead of `[` consistently.
- Miscellaneous early return fixes, e.g. for conda and virtualenv detection.
- Renamed RHEL scripts to use Fedora instead. Improved check support for distros
  that extend Fedora, such as RHEL 7 and Amazon Linux 2.
- Simplified shellcheck installation across distros.
- Improved conda installation messages.

## koopa 0.3.5 (2019-06-04)

This version introduces a fair number of changes, in preparation for future
v0.4 release series. They should be breaking changes, so we indicated this as
a point release instead.

### Major changes

- koopa now clones Mike's dotfiles repo as a submodule, in `dotfiles/`.
- Moved install scripts from `install/` into nested inside `bin/` instead.

### Minor changes

- Reorganized exported scripts in `bin/` directory.
- Improved platform checks and related messages.
- Moved `sudo-*` scripts into nested `sudo/` directory, to allow conditional
  access in `$PATH` export for sudo users only.
- Improved `check-versions` script to determine if R is installed. Added
  additional improvements to the R code for these checks.
- Azure: `rsync-azure-files`: Now excluding `work/` directories, for bcbio.
- Initial setup of sudo scripts for RHEL 7.
- Improved information shown in `koopa-info` script.

### New programs

- `install-doom-emacs`: Setup script for doom-emacs.
- `install-genrich`: Install Genrich caller for ChIP/ATAC-seq.
- `install-python-virtualenv`: Updated to support Python 3.
- `install-rmate`: Useful utility for opening remote scripts in VS Code.
- `install-spacemacs`: Install script for spacemacs (emacs+vim editor).
- `youtube-mp3`, `youtube-thumbnail`: New `youtube-dl`-related utility scripts.

### Additional files

- Added support files for fedora `ldconfig` in `etc/ld.so.conf.d/`.
  This are particularly useful for configuring programs installed at
  `/usr/local`, and for R to correctly pick up library dependencies.

## koopa 0.3.4 (2019-05-24)

- Improved version dependency checks.
- Added new `check-versions` program, for additional version checks.
- Improved build scripts in `install/` to use `/tmp/` for temp files.
- New build scripts: bash, coreutils, gnupg, openssl, pass, r, rstudio-server,
  and zsh.
- Now using a shared `__init__.sh` script for simpler build dependency checks.

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

## koopa 0.2.4 (2019-01-09)

### Major changes

- Reworked activation script to use POSIX instead of bash conventions. Notably,
  this involves switching to `[` from `[[`.
- Early return using `return` instead of `exit` when koopa is already active,
  to prevent accidental lockout on a remote SSH connection.

### Minor changes

- Improved support for ZSH in activation script.
- Initial commit of `NEWS` file.
- Now checking on Travis CI only against master branch.

## koopa 0.2.3 (2019-01-01)

### Minor changes

- Improved variable quoting inside `bin/` scripts.
- Reworked activation steps in main `activate.sh` script.
- Deleted `reference.txt` file in `system/`.
- Deleted function scripts inside `functions/`. Rethinking this approach.

### Removed programs

- Deleted `sam_to_bam` utility script.

## koopa 0.2.2 (2018-12-19)

### New programs

- Added `trash` utility, which moves files to `~/.Trash`, similar to macOS.

### Removed programs

- Removed `sudo_install_git` and `sudo_install_r_cran`. Rethinking this
  approach in a future update.
- Removed these macOS-specific scripts: `brew_cleanup`, `brew_status`,
  `brew_upgrade`, `install_homebrew`, and `install_openssl`.

### New functions

- Added `path_modifiers.sh` and `quiet_which.sh` utilty functions.

### Minor changes

- Improved error message for unsupported shells in `koopa`.

## koopa 0.2.1 (2018-11-24)

### New programs

- Added `git_push_all` and `git_status_all`, corresponding to `git_pull_all`.

### Minor changes

- Improved comments regarding HISAT2 for bcbio.
- Reorganized interactive and non-interactive script handling in `system/`.
- Hardened shell scripts using `set -Eeuo pipefail`.

## koopa 0.2.0 (2018-09-23)

Now exporting new scripts in `bin/`, accessible in `$PATH`.

### Major changes

- Reworked `koopa.sh` to be exported in `bin/` as simply `koopa`.
- Reorganized activation scripts. Split out aliases into `01_aliases.sh`.
  Improved automatic activation scripts for HPC and PATH exports.
- Improved activation handling in `activate.sh`.
- Added new `info.sh` info box utility script.
- Added `list.sh` program list utility.

### Minor changes

- Reorganized activation script for login / non-login and interactive /
  non-interactive shells.

## koopa 0.1.2 (2018-09-05)

- Improved automatic configuration for bcbio on Harvard HPC clusters.
- Improved GENCODE workflow scripts.
- Improved automatic conda configuration.

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
