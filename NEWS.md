# Release notes

## koopa 0.13.4 (2023-07-28)

Major changes:

- Removed support for `python3.10`. Updated `google-cloud-sdk` and `latch` to
  depend on `python3.11`.
- Improved internal consistency of `aws` cli command syntax and JSON return.

Minor changes:

- Updated apps: `anaconda`, `aws-cli`, `broot`, `chezmoi`, `conda`,
  `difftastic`, `gh`, `google-cloud-sdk`, `gum`, `htslib`, `latch`,
  `libarchive`, `lmod`, `multiqc`, `node`, `nushell`, `openbb`, `pandoc`,
  `pyenv`, `rclone`, `ruff`, `samtools`, `snakemake`, `tbb`, and `visidata`.
- Reverted `prettier` from 3.0.0 back to 2.8.8 to avoid breaking changes with
  JSON sorting plugin.
- Renamed `koopa_aws_ec2_suspend` to `koopa_aws_ec2_stop`, matching the current
  syntax conventions of AWS CLI.
- Add notes on GENCODE handling during salmon indexing and quant. We're working
  on improving the sanitization of GENCODE FASTA files to avoid identifier
  issues related to usage of the non-standard `|` delimiter instead of spaces,
  which will be deployed in a pending `r-acidgenomes` package update.

New functions:

- `koopa_aws_ec2_list_running_instances`: List currently running EC2 instances.
- `koopa_aws_ec2_map_instance_ids_to_names`: New convenience function that
  returns mappings of AWS EC2 instance identifiers to defined human-friendly
  names (aliases).

## koopa 0.13.3 (2023-07-17)

New apps: `blast`, `jless`, `ronn-ng`, and `wget2`.

New binaries:

- `ip-info`: Detailed information on current IP address, including city,
  organization, and timezone. Returned in JSON format.

Major changes:

- `koopa_download` function has been overhauled and simplified to only wrap
  `curl`. Support for `wget` engine has been dropped from this function.
- Improved R system configuration.
- Improved cross-platform and cross-shell compatibility of some convenience
  aliases, most notably `conda` and `z` (for zoxide).

Minor changes:

- Fixed typo in `koopa_aws_s3_delete_versioned_glacier_objects` name.
- The `koopa install` command now supports positional arguments with `--all`
  and `--all-binary` flags set.
- Definition lists are no longer bold by default.
- `koopa_docker_run` now allows unauthenticated pulls from AWS ECR. To enable
  authenticated pulls, ensure that `AWS_ECR_ACCOUNT_ID`, `AWS_ECR_PROFILE`, and
  `AWS_ECR_REGION` environment variables are defined.
- Binaries are now only pushed consistently when `--push` flag is set.
- Relaxed apt configuration for new Debian 12 instances.

## koopa 0.13.2 (2023-06-28)

Major changes:

- Added support for salmon quantification directly from BAM files. Using this
  code to process Nanopore output aligned with minimap2.
- Improved handling of FASTQ symlinks in kallisto and salmon functions.
- Improved parameterization of `koopa_sub`, ensuring that both regex and fixed
  modes work as expected.
- Apps that depend on Node no longer attempt to burn in module path.

Minor changes:

- Updated Posit package manager (for R) snapshot to 2023-06-23.
- Reworked `ont-dorado` install support, using pre-built binaries instead of
  attempting to install from source using CMake.
- Simplified and reworked file rename functions: `koopa_rename_camel_case`,
  `koopa_rename_kebab_case`, `koopa_rename_snake_case`.
- Removed support for `curl7`, now that we can convince R that `curl` 8 is OK.
- `extract` and `find`: Improved handling of hidden dot files when using GNU
  find, which we detected when attempting to install `ont-dorado` inside a Linux
  Docker instance.
- Export of `EDITOR` value now only defines koopa vim when it is installed.
- `koopa_is_ssh_enabled` no longer errors if `ssh` is not installed.
- Fixed cryptic R build error seen on macOS (4.3.1) that was due to usage of
  GNU binutils `ar` instead of system `ar`.
- Added support for locating `gunzip` and `minimap2`.
- Relaxed Renviron PATH checks for directory paths that may not exist.
- Homebrew updater now untaps deprecated `homebrew/cask-drivers` tap.
- Our `koopa_dot_clean` function now uses `koopa_find` internally.
- R system configuration now removes legacy `Makevars.site` file on Linux.

New installers:

- Added install support for `libaec`, which is now a dependency for `hdf5`.
- Added install support for `mold`.

## koopa 0.13.1 (2023-06-02)

Major changes:

- Reworked `decompress` and `extract` functions. Added support for additional
  compression formats, including brotli, lz4, lzip, and zstd.

Minor changes:

- Removed `decompress` from koopa bin. We recommend using `extract` instead,
  which supports multiple archive formats, including compressed files.
- Removed install support for `yarn`, which is now bundled inside of `node`.
- Renamed `defaults` configuration to `preferences` on macOS.
- Renamed `defaults` configuration to `base` on Debian.
- Added `ca-certificates` activation function.
- Improved time zone configuration handling on Debian systems not booted with
  systemd (e.g. Latch Pods).
- Hardened extraction steps inside of installers, where applicable.

New installers:

- Added support for `apache-arrow`, `krb5`, `ldns`, `libcbor`, `libfido2`,
  `libxcrypt`, `p7zip`.

## koopa 0.13.0 (2023-05-25)

This is a big update, with thousands of changes since our prelease stable
0.12.1 release in 2021. Documentation explaining these changes in more detail
will be added to the main koopa website in the next few months.

Major changes:

- Added install support for hundreds of commonly used programs.
- Added application-specific functionality in the CLI under `koopa app`.
- Dotfiles are now version pinned. These can be configured by first installing
  with `koopa install dotfiles` and then configuring using
  `koopa configure user dotfiles`.
- Renamed and reorganized internal function library. Bash scripts are now
  consistently prefixed with `koopa_`. Note that POSIX shell scripts are
  prefixed with `_koopa_`.

Major changes:

- Removed automatic dotfiles installation from main installer.

## koopa 0.12.1 (2021-10-05)

Major changes:

- Improved internal subshell handling, which now avoids the duplicate tmux
  session messages seen on EC2 instances.
- Internal `install_app` function now provides better support for non-default
  `--prefix` handling, which is useful for configuration on AWS EC2 instances.
  In particular, this is useful for installing large programs onto internal
  volumes, such as bcbio-nextgen.
- `aws_s3_sync`: Improved array handling of `--exclude` patterns.
- `generate_ssh_key`: Defaulting back to `id_rsa` instead of `id_ed25119`, which
  still has better general compatibility support on AWS, in particular with
  regard to CodeCommit. May revert back in a future update, but now is not
  the time.
- Improved the consistency (i.e. standardized) the configuration of language-
  specific package libarries, including Julia, Nim, Node, Perl, Python, R,
  Ruby, and Rust.
- Improved Docker install support on Debian 10 and Ubuntu 20.

Minor changes:

- Simplified Homebrew activation and R configuration on Linux.
- Updated RSPM CRAN snapshot to 2021-10-05.
- Added installation and auto-completion support for `nim` and `nim-packages`.
- Homebrew link fixes for `nghttp2`/`libnghttp2` and `python@3.9`.
- Miscellaneous package version updates in `variables.txt`.
- Updated conda recipe versions and added `mirdeep2` to bioinfo recipes.
- `python_get_pkg_versions`: Split out this function, which is shared in
  pip installer calls during standard Python package install, and in our
  `r-reticulate` virtualenv generator.
- `init_dir`: Improved detection and handling of input containing user home
  directory abbreviated as `~`.
- Emacs needs to be in path for our Doom Emacs updater.
- Improved consistency of kallisto and salmon output directory handling in
  their respective `index` functions.
- Simplifed Emacs locator function approach on macOS.
- Shared profile configuration file in `zzz-koopa.sh` should use `.` instead
  of `source` in the call, which is POSIX-compliant.
- Improved support for Prelude Emacs.

## koopa 0.12.0 (2021-09-21)

Major changes:

- All functions supporting long flag arguments (e.g. `--argument=VALUE`) now
  also support the `--argument VALUE` positional variant, which are easier to
  code inside Python/R wrapper functions.
- Added single-end sample processing support for kallisto and salmon.
- Improved Homebrew (Linuxbrew) support for Linux. Split out the brewfiles into
  separate files that we can share across Linux and macOS. This is still a bit
  of a work in progress, and may change in the future. In particular, support
  for Homebrew on ARM Linux is currently quite poor and helps development help.
- Reworked and improved AWS CLI utility functions. In particular, `aws_s3_ls`
  is improved to better pick out directories and files, using `awk` now
  internally. All AWS functions now support non-default CLI profiles, either
  using `AWS_PROFILE` global variable, or `--profile` argument.
- Hardened `PATH` and `PKG_CONFIG_PATH` inside of install and update function
  calls, where applicable.
- Reverted use of `_koopa_conda_alias` back to full conda activation inside of
  interactive shells. Use of this approach was resulting in weird behavior on
  Debian 11 ARM test AWS AMI image.

Minor changes:

- `run-kallisto` is now a symlink to `run-kallisto-paired-end`, and
  `run-salmon` is now a symlink to `run-salmon-paired-end`.
- Our default `condarc` file inherited by conda now uses capitalized `True`
  and `False` values, recommended by Bioconda. Also disabling auto update of
  conda in this config by default.
- Improved auto-completion support for main `koopa` program.
- Improved conda detection support inside of active R session.
  See `Rprofile.site` file for details.
- Updated RSPM snapshot from 2021-07-01 to 2021-09-21.
- Increased default timeout in R configuration.
- Improved configuration when handing off to r-koopa package.
  See `header.R` file for details.
- All case switch statement arguments are now quoted, where applicable.
- Improved CLI handoff to r-koopa.
- Renamed `is_git` function to `is_git_repo`.
- Added draft support for Debian 11 Bullseye release.
- Reorganized installer functions, adding an additional level of nesting in
  directory hierarchy.
- Internal koopa coreutils functions now support long `--sudo` argument instead
  of simply using `-S`, which is more readable.
- Added more internal program locator functions.
- Improved functions that extract program versions.
- Miscellaneous improvements to non-interactive and interactive shell activation
  functions.
- Improved handling of Emacs configuration on macOS.

Removed functions:

- Removed `indrops-i5-sample-index-counts`, which has been migrated to r-koopa
  package instead.

## koopa 0.11.1 (2021-07-12)

Minor changes:

- Updated Python dependencies. Also updated other versions as recommended by
  latest Homebrew update.
- Updated r-koopa dependency to 0.1.20.
- Updated RStudio Package Manager (RSPM) to 2021-07-01.

## koopa 0.11.0 (2021-06-28)

This is a significant release that overhauls a number of functions in the Bash
library, with the intent to improve standardization of app configuration.

Major changes:

- Overhauled and significantly improved completion support for main `koopa`
  script on Bash and Zsh. Added support for nested completion of `install`
  and `uninstall` here, which is very useful for quickly identifying which
  install scripts are supported for a specific platform (e.g. macOS or Linux).
  Internally reduced the complexity by simplifying the number of calls to
  `COMPREPLY`.
- Reworked main shell activation script defined in `activate` file. This now
  defines some standard POSIX functions internally, and then hands off to
  POSIX shell library inside of POSIX header file to complete the activation
  process. This helps improve configuration consistency when `koopa` is
  called externally outside of our Bash or Zsh configuration files.
- Improved standardization (and consistency) of installer functions by
  using new `install_app` and `uninstall_app` wrapper functions. These help
  improve the consistency of linking into `app/` and `opt/` subdirectories
  inside of koopa installation.
- Hardened coreutils and other commonly used external programs with function
  wrappers, with the intent to improve consistency across platforms. This
  applies primarily to GNU coreutils, which can be distributed instead as
  BSD variants on some platforms (e.g. macOS, Busybox). These wrappers are
  named with `locate_*` prefix internally in the Bash library.
- Added initial support for Julia package management with
  `koopa install julia-packages`.
- Reworked `julia-packages`, `perl-packages`, `r-packages`, `ruby-packages`,
  and `rust-packages` structure in `app/`. These now contain versioned
  subdirectories consistently, similar to installed apps. The latest version
  is now linked into `opt/`.

Minor changes:

- Added support for new Rocky Linux distribution, which aims to replace
  CentOS 8 for HPC configurations.
- Updated multiple dependency version checks. Refer to `include/variables.txt`
  for a diff of all specific changes.
- Updated R RSPM CRAN shapshot for Linux to 2021-06-16 in `Rprofile.site` file.
- Hardened R CRAN binary check on macOS in `Rprofile.site` file.
- Renamed `current-bioc-version` to `current-bioconductor-version`.
- Renamed `current-bcbio-version` to `current-bcbio-nextgen-version`.
- Removed `tldr` custom code, in favor of using Rust `tealdeer` to manage
  tldr look-ups.
- Prefixed all `venv-*` exported scripts and functions with `python-*`.
- Removed `goalie::isCleanSystemLibrary` check inside of R script header,
  which can be overly strict. This check currently fails on Debian/Ubuntu
  CRAN binaries for R 4.1.0.
- Simplified conda environment handling in `activate_conda_env` function.
- Initial commit of `koopa_find` internal function, which attempts to use
  Rust `fd` instead of GNU `find` when possible.
- Improved support for multiple Emacs configurations (e.g. Spacemacs,
  Doom Emacs, etc.) using chemacs2 approach.
- Reorganized R configuration files, to better support new 4.1 release.
- Reworked some linter checks that are called by `koopa system test`.
  Some of these checks will migrate to new AcidLinter package in the future.

## koopa 0.10.2 (2021-05-18)

Minor changes:

- R configuration updates to provide compatibility with R 4.1. Refer to
  `Renviron.site` files for configuration changes. Note that R configuration
  defined in `etc/` is now versioned to support 4.1 in addition to 4.0, 3.6,
  and devel releases.

## koopa 0.10.1 (2021-05-16)

Major changes:

- Reworked shell detection and export of `KOOPA_SHELL`, `SHELL` variables
  during activation. This now should consistently return the full path to the
  current shell application, including in subshells.
- Improved consistency of Miniconda (default) and Anaconda installs.
- The `koopa_downloader` function now calls `wget` instead of `curl` when
  under qemu emulation (e.g. ARM Docker image running on x86 Intel machine).
  This is not common but helps avoid edge case issues with curl currently
  crashing with a segfault for some HTTPS URLs that fail specifically when
  called in qemu emulation environment. This was noted to happen with the
  `repo.anaconda.com` server, for example.

Minor changes:

- Updated the dependency versions for recommended conda bioinfo environments.
- Reworked the `conda_create_bioinfo_envs` function to use a dictionary
  approach, which better supports a lot of variables in use. Added some more
  tools potentially useful for enrichment (i.e. MIME Suite) and for single-cell
  and spatial analysis.
- Now wrapping calls to `conda` in a variable, in case we want to dynamically
  switch to using mamba when mamba is installed.
- Potentially empty arrays have been appended with `:-`, to avoid some potential
  issues with Bash running in `-u` (no unbound variable) mode.
- Reverted Docker builds to check for builds older than 7 days instead of 30
  by default.
- The `docker_run` function now supports a `--bind` argument, enabling bind
  mode of the current working directory.
- Internal `*has_sudo` functions have been renamed to `*is_admin` instead,
  which makes more sense for a root user.
- Improved error message when attempting to install on macOS with ancient Bash.
- Updated Conda installer to use Python 3.9, which now also provides initial
  support for aarch64 (ARM) platform in addition to x86.

## koopa 0.10.0 (2021-05-11)

Major changes:

- This release introduces a overhaul to the internal app install engine defined
  in the `koopa_install_app` function. Primarily this helps improve app
  installation consistency into `app/<version>/<name>` with subsequent
  unversioned links in `opt/<name>`, similar to the current approach used in
  the Homebrew package manager.
- Migrated all app installer code from `include/install` into the main Bash
  function library. These get defined internally (as `__koopa_install_bash`,
  for example). Then they are called from `koopa_install_bash`, which
  subsequently hand off to `koopa_install_app` for improved linkage and
  permission consistency.
- The main `koopa_install_app` installer function now hardens `PATH`,
  `PKG_CONFIG_PATH` and other variables for improved installation handling.
- App installs now rely on koopa opt (e.g. `/opt/koopa/opt/<name>`) and
  Homebrew opt (e.g. `/usr/local/opt/<name>`) for app installs. This really
  helps improve installation recipes to build successfully on macOS.
- Reworked the Perl, Python, R, Ruby, and Rust package configuration. Now all
  of these link consistently into koopa opt (e.g. `/opt/koopa/opt/r-packages`
  for R; `/opt/koopa/opt/python-packages` for Python). Packages should never
  get installed into the system site libraries and/or inside Homebrew.
- R site configuration has been updated to use the same path for `R_LIBS_SITE`
  and `R_LIBS_USER`. If `R_LIBS_USER` is not the same, RStudio Server will now
  create an unwanted user package directory. This is not the case with base R
  or the RStudio app on macOS.
- Added macOS dark/light mode detection support. The shell session now sets
  the `KOOPA_COLOR_MODE` variable, which can get picked up in supported iTerm2
  and Vim configurations. We currently recommend using Dracula for dark mode
  and Solarized Light for light mode where possible. This currently applies to
  our Vim and Spacemacs (Emacs) configurations.
- Reworked main activation script.
- Improved completion handling support for Bash.

Minor changes:

- Multiple updates to dependency package versions.
- Updated r-koopa check to v0.1.18.
- Improved consistency of `--reinstall` flag handling for app installs.
- Improved dircolors handling on macOS.
- Removed some exported apps in `PATH` that are not frequently used.
- Improved architecture support (i.e. x86, ARM) in some install scripts.
- GDAL installer no longer attempts to install Python code, which links into
  system site library, no matter the Python configuration.
- Hardened internal downloader function (`koopa_download`) to ignore manual
  user cURL configuration defined in `~/.curlrc`.

## koopa 0.9.4 (2021-04-09)

Major changes:

- Reworked activation of GNU coreutils on macOS, significantly speeding up
  the loading time.
- Useful GNU utitiles on macOS from Homebrew are now defined as aliases
  (e.g. 'gcp' is aliased to 'cp'). The original BSD variants are consistently
  prefixed with 'bsd' (e.g. 'bsdcp' for 'cp').

Minor changes:

- Updated system dependency checks. Now intentionally errors when attempting
  to run inside a Docker image.
- Shared `Rprofile.site` configuration is now respectful of quiet mode,
  defined with either '--quiet', '-q', or '--silent' flags.

## koopa 0.9.3 (2021-03-31)

Minor changes:

- Improved activation speed of Homebrew GNU utilities on macOS.
- Updated dependency versions.

## koopa 0.9.2 (2021-03-30)

Major changes:

- Improved support for 64-bit ARM (AArch) in addition to x86. Installers and
  other platform-specific scripts now use `koopa_arch` function internally
  when applicable. Note that ARM is still not well supported in some
  bioinformatic workflows, RStudio installers, and conda.

Minor changes:

- Updated package versions supported by installers.
- Improved shared R profile configuration to suppress messages regarding manual
  CRAN configuration that now pop up with the BiocManager update.

## koopa 0.9.1 (2021-03-01)

Minor changes:

- Reorganized some internal Bash functions.
- Improved and hardened functions that can enable passwordless sudo or sudo
  via Touch ID on macOS.
- Updated package version checks to support more libraries, such as cairo,
  harfbuzz, and imagemagick. These checks are defined in the r-koopa package.

## koopa 0.9.0 (2021-02-16)

- Installer now defaults to `/opt/koopa` instead of `/usr/local/koopa`.
- Reworked organization of "cellar" and "app" prefixes. Removing the usage of
  "cellar", since this is a Homebrew-specific idiom. Instead koopa will now
  use "app" for versioned installed, and a nested "opt" directory for
  unversioned symlinks, similar to the approach used by Homebrew.
- Removed autojump activation support in favor of zoxide, which is faster.
- Massive rework of internal shell script function library, which is now
  defined inside `lang/shell` (see `bash` and `posix` subdirectories).
- Offloaded some functionality to koopa R package, which can be installed
  if necessary with `koopa install r-koopa`.

## koopa 0.8.9 (2020-10-09)

Minor changes:

- Improved internal code that checks for unstaged changes in current Git repo.
- Updated r-koopa dependencies.
- Updated RSPM snapshot to 2020-10-06.

## koopa 0.8.8 (2020-10-06)

Minor changes:

- Upgraded Python from 3.8.5 to 3.9.0.
- Upgraded GDAL from 3.1.2 to 3.1.3.

## koopa 0.8.7 (2020-10-05)

Minor changes:

- Updated RSPM to 2020-10-01 snapshot.
- Updated check against Ruby version.

## koopa 0.8.6 (2020-09-22)

Minor changes:

- Updated bcbio-nextgen version to 1.2.4.

## koopa 0.8.5 (2020-09-18)

Minor changes:

- `koopa header`: Added support for R. Input is no longer case sensitive.
- Improved broot activation support on macOS.
- Updated OpenJDK to 15.
- Updated RStudio Package Manager (RSPM) snapshot to 2020-09-16.
- Updated GDAL, Go, and htop versions.

## koopa 0.8.4 (2020-09-09)

Minor changes:

- Improved `install-rust-packages`, pinning to specific Rust versions.
  User can define custom packages to install as positional arguments, following
  the conventions used for `install-python-packages`.
- Activation fix for broot on macOS. The location of the br activation script
  has changed recently.
- broot configuration is now under Git in the dotfiles repo.

## koopa 0.8.3 (2020-09-08)

New software recipes:

- Added install support for bpytop.

Minor changes:

- Updated r-koopa dependency to 0.0.7 from 0.0.4.
- Updated htop installer to use new forked repo.
- Updated RStudio Package Manager (RSPM) snapshot to 2020-09-01.
- Miscellaneous software version updates: Aspera Connect, GDAL, PROJ.

## koopa 0.8.2 (2020-09-02)

New software recipes:

- Added taglib cellar recipe. Also added dependency support for Debian,
  Fedora, and RHEL.

Minor changes:

- Added support for `koopa fix-zsh-permissions`.
- Miscellaneous software dependency version updates.

## koopa 0.8.1 (2020-08-25)

Minor changes:

- Updated r-koopa dependency from 0.0.1 to 0.0.4.
- Use single quotes in shell when possilble, to pass lintr checks.
- Cleaned up comments in `Rprofile.site` file.
- Draft support for pytaglib installation.
- `drat`: Switched default path to `~/monorepo/drat`.
- Updated pinned `pip` dependency version.

## koopa 0.8.0 (2020-08-18)

This release migrates all internal Bash code to functions in a shared library.

Major changes:

- Repackaged all internal Bash code inside exported scripts to function library
  in `shell/bash`. Refer to scripts inside `bin` or `sbin` for examples.
- Split out internal Python code into new separate Python package.
- Split out internal R code into new separate R package.

New scripts:

- Now exporting: `convert-utf8-nfd-to-nfc`, `current-bcbio-version`,
- `delete-adobe-bridge-cache`, `docker-remove`, `docker-run-wine`, `drat`,
  `file-count`, `find-and-move-in-sequence`, `git-rm-submodule`, `install-pip`,
  `install-ruby-packages`, `jekyll-serve`, `line-count`, `move-files-in-batch`,
  `rename-snake-to-kebab`, `rsync-ignore`, `update-r-config`, `url-encode`,
  `venv-create`, `youtube-mp3`, `youtube-thumbnail`.
- New macOS scripts: `brew-outdated`, `clean-launch-services`, `ifactive`,
  `install-pytaglib`, `list-launch-agents`, `merge-pdf`.
- New Raspbian scripts: `install-pihole`, `install-pivpn`.

Removed scripts:

- Removed unnecessary exported scripts: `docker-build-all-batch-images`,
  `emacs-vanilla`, `emacs24`, `install-chrohmm`, `nvim-vanilla`,
  `rename-fq-to-fastq`, `sha256`, `tar-c`, `tar-x`, `update-google-cloud-sdk`,
  `update-python-packages`, `vim-vanilla`.

Minor changes:

- Tightened up internal R code used for `koopa check-system` and `koopa list`.
- Simplified version checks inside R header.
- Working toward improving roff documentation (inside `man` directories) using
  [ronn](https://github.com/rtomayko/ronn).
- Improved Wine installer on Debian and Fedora.
- Reorganized and reworked bcbio scripts for Linux.

## koopa 0.7.0 (2020-07-15)

This is a pretty major update, where a lot of the internal functions have been
overhaluled and improved.

Major changes:

- Documentation has been migrated into `man`-compatible format, and are now
  saved in `man/man1/`. These are accessible per program via the `--help`
  flag, which now spawns `man` internally. Python scripts still use the
  argparser help format.
- Renamed all internal shell functions with `koopa_` prefix instead of previous
  `koopa_` prefix. Note that we always want to use an internal prefix, so we
  don't accidentally mask any system functions defined for bash and/or zsh
  loaded by other program scripts. For example, be careful not to mask
  `deactivate` for Python venv.

Minor changes:

- Reorganied bcbio admin scripts previously defined for Azure VMs. Migraged
  these scripts to Linux `sbin/`.

## koopa 0.6.0 (2019-10-14)

New scripts:

- Added syntactic naming scripts: `camel-case`, `kebab-case`, `snake-case`, and
  `make-names`. These scripts support file renaming via glob matching with the
  `--rename` flag. They call the [syntactic][] R package internally.
- `install-rstudio-server-pro`: Added support for RStudio Server Pro
  installation on Fedora / RHEL.
- `download-cran-latest`: Pull down the latest R package release from CRAN.
- Added support for RefSeq genome with `download-refseq-genome`. Can get current
  RefSeq release version with `refseq-version` script.
- `install-python-pip`: Quickly install `pip` into current Python library.
- Added cellar scripts for: `genrich`, `lua`, `luarocks`, `neofetch`, `rmate`,
  `shellcheck`, and `sra-tools`.
- Added internal version detection scripts via the shell for multiple programs,
  including bash, bioconductor, clang, condam docker, emacs, etc.
  See `system/include/version` for scripts.

Major changes:

- Improved prompt string configuration support and colors for git, conda
  environent, and Python virtual environment (venv) names. The internal code
  has been consolidate and simplified, for improved consistency between bash
  and zsh shells. Note that bash uses "$" prefix, whereas zsh uses "%".
- Now defining pykoopa Python import internally in the package, making it easier
  to share functions across Python scripts exported in `bin/`.
- Updated dotfiles configuration to use pylint and flake8 for Python checks.
  See separate dotfiles repo for changes.
- Improved conda environment creation scripts. New `conda-create-env-bioinfo`
  automatically sets up multiple useful environment for bioinformatics.
  Added general `conda-create-env` and `conda-remove-env` scripts for quick
  environment creation and deletion.
- Renamed and reworked genome download scripts:
  `ensembl-fasta`, `ensembl-gtf` merged into `download-ensembl-genome`;
  `flybase-fastq`, `flybase-gtf` merged into `download-flybase-genome`;
  `gencode-fastq`, `gencode-gtf` merged into `download-gencode-genome`.
- Renamed rsync scripts for Azure VM admin. Now prefixed with `rsync-*`.
- Added additional internal POSIX functions, including assert checks.
- GNU coreutils are now included in PATH for macOS, when installed via
  [Homebrew][]. Normally they are prefixed with "g" on macOS instead.

Minor changes:

- Added 'download-' prefix to FASTA and GTF download scripts.
- Improved Emacs `emacs` and `spacemacs` configuration files inside the dotfiles
  repo, based on some issues seen in the Emacs GUI on macOS.
- Added R lintr config to check R scripts.
- System linter used for CI checks can now check against Python scripts.
- Migrated away from `source "$(koopa header bash)"` method to sourcing internal
  functions via a relative path instead.
- Removed some unused scripts: `extract-fastq`, `ffmpeg-*`, `gzip-dir`.
- Added draft configuration of 24-bit terminal color support with `terminfo`.

## koopa 0.5.6 (2019-09-18)

New scripts:

- `gencode-fasta` and `gencode-gtf` Python scripts for downloaded GENCODE
  genome annotations. Currently supports _Homo sapiens_ and _Mus musculus_.
- (Azure) `link-msigdb`: Shared MSigDB file annotation utility.

Minor changes:

- Improved global activation of general exports, including `EDITOR`, which
  defines the default text editor. "vim" is recommended by default but "emacs"
  is also a good choice.

## koopa 0.5.5 (2019-09-09)

Major changes:

- Updater now checks for: oh-my-zsh, spacemacs symlinks in config directory.

Minor changes:

- Added install support for ChromHMM.
- Bug fix for directory creation in Python cellar script.
- ZSH configuration improvements.

## koopa 0.5.4 (2019-09-05)

Minor changes:

- Improved alias handling for zsh configuration.
- Added additional useful aliases and functions from Stephen Turner's oneliners
  guide for bioinformatics.
- Initial configuration support for autojump, currently limited to zsh. Will
  test and add bash support in a future update.

## koopa 0.5.3 (2019-08-28)

Minor changes:

- Improved zsh activation and oh-my-zsh configuration handling when koopa is
  active inside `/etc/profile.d/` on Linux (i.e. RHEL 7).

## koopa 0.5.2 (2019-08-18)

This release improves prompt consistency between zsh and bash.

Minor changes:

- Reworked prompt string configuration. Now automatically updates correctly
  when either a conda environment or Python virtual environment are loaded.
  Removed shell version and disk usage from the prompt.
- Updated zsh shell configuration to use our custom, more minimal koopa prompt
  instead of Pure prompt. This prompt is visually identical to our bash PS1.
- Reduced the number of available string returns from main `koopa` function.
  Instead, these are now called more consistently using internal prefixes.
  (e.g. `koopa_cellar_prefix` instead of `koopa cellar-prefix)`.

## koopa 0.5.1 (2019-08-15)

Minor changes:

- Bug fixes for koopa activation inside a subshell (e.g. tmux or slurm queue).

## koopa 0.5.0 (2019-08-14)

Major changes:

- Koopa now attempts to source user configuration files prior to activation.
  This enables better passthrough of user-defined configuration variables.
- Simplified dotfiles configuration handling. Now need to install manually using
  `--dotfiles` flag or can use `install-dotfiles` script after installation.
- Fixed shell configuration when `EDITOR="emacs"`.

## koopa 0.4.6 (2019-08-01)

New scripts:

- `ftp-mirror`: Script that helps quickly mirror an FTP directory using wget.
- `install-rcheck`: Utility for quickly checking R packages.

Minor changes:

- Reworked the file paths of some dot files related to vim and zsh config.
- Improved `docker-run-image` workdir configuration.
- Improved shell checks, following shellcheck 0.7 release updates.
- Relaxed checks in Debian and Fedora headers when running as sudo user.

## koopa 0.4.5 (2019-07-29)

Minor changes:

- Improved detection and handling of unbound variables during installation and
  activation of koopa.

## koopa 0.4.4 (2019-07-28)

New scripts:

- `ffmepeg-alac-to-flac`, `ffmepeg-flac-to-alac`: Lossless audio conversion.
- `move-into-dated-dirs-by-filename`: Automatically move files containing a
  date (e.g. `2019-07-28-12-01-59.txt`) into dated subdirectories
  (e.g. `2019/07/28/`).
- `move-into-dated-dirs-by-timestamp`: Automatically move files into a dated
  subdirectory according to its timestamp.
- `sox-downsample`: Utilty script for easily downsampling high resolution audio.

Darwin (macOS)-specific:

- `delete-adobe-bridge-cache`: Delete Adobe Bridge cache files.
- `dotfile-icloud`: Dot file utility for linking from iCloud, instead of our
  dotfiles git repo.
- `update-defaults`: Utility for setting recommended defaults. Modifies some
  finder settings, screen shots path, etc.

Debian-specific:

- `install-git-lfs`: Utility script for installing Git LFS.

Fedora-specific:

- Added additional packages to install via yum by default.
- `install-cellar-gdal`: New recipe required to install rgdal R package.
- `install-cellar-proj`: New recipe required to install rgdal R package.

Major changes:

- Installation will now clone private scripts and docker recipes. The activation
  script now knows to look for these and will add `bin/` directories to `PATH`.

Minor changes:

- Reworked linter engine to check for maximum of 80 characters per line.
- Improved internal update timestamp consistency across files.
- Improved shared Renviron and Rprofile site configuration files.

## koopa 0.4.3 (2019-07-25)

New scripts:

- `docker-run-image`: Useful utility script for booting a Docker image.
- `patch-bcbio`: Utility for patching bcbio development installation from
  GitHub codebase.
- `upgrade-bcbio`: Utilty for upgrading bcbio on a virtual machine.

## koopa 0.4.2 (2019-07-12)

Minor changes:

- Improved automatic XDG configuration in `~/.config/koopa`. Needed to update
  configuration of R symlink.

## koopa 0.4.1 (2019-07-11)

Major changes:

- Removed support for ksh. This shell does not support usage of `local`
  variables inside of functions, which are tremendously useful, and prevent
  accidental variable overwrites. Therefore, we're restricting support for
  bash and zsh at the moment.
- Improved Fedora install scripts to support RHEL 8. Also updated Docker install
  script to support RHEL 8.

Minor changes:

- Harden scripts to pass shellcheck.
- Switch back to using `-n` instead of `! -z` consistently for POSIX code.
  Double checking, this works correctly with latest version of ZSH.
- Sort arrays using `mapfile`, which is recommended by shellcheck.
- Improve shebang detection inside recursive shellcheck script.
- Added fixme/todo comments detection in linter script.
- Updated recommended program versions.
- Improved version checks inside `check.R` script.

New programs:

- Added `copy-bam-files` utility, which makes it easier to quickly set up an
  IGV session, which requires both `*.bam` and `*.bam.bai` files. Previously,
  this was named `cp-bam-files`.

## koopa 0.4.0 (2019-06-13)

This is the first release supported to work when installed at `/usr/local`.
This enables shared shell configuratino of all users, via configuration in
`/etc/profile` (or `/etc/profile.d/`) instead of relying on `.bash_profile`.

Major changes:

- koopa now checks for root and doesn't attempt to activate.
- Improved dotfile initialization, and no files are overwritten by default.
- Reworked `install` script, and added usage accessible via `--help`.
- Added `uninstall` utility script.
- Reworked activation scripts to support multi-user config.
- Reworked shared script header approach.
- Improved automatic `/etc/` configuration.

Minor changes:

- `KOOPA_PREFIX` path is always expanded, and symlinks are now resolved.
- Improved Travis CI testing approach.
- Reorganized workflow scripts.
- Split out functions into individual scripts.

## koopa 0.3.6 (2019-06-05)

Major changes:

- Improved update script.
- Install koopa using simply `install` instead of `INSTALL.sh`.
- Improved attempt at dotfiles auto-linking during `install` call.
- Improved OS-specific PATH exports.
- Switched to using `KOOPA_BUILD_PREFIX` and `KOOPA_TMP_DIR` variables for
  build scripts.

New programs:

- `sudo-install-amzn-base`: Recommended initial setup for Amazon Linux 2.
- `sudo-install-debian-base`: Recommended initial setup for Debian.
- `sudo-install-fedora-base`: Recommended initial setup for Fedora.
- `sudo-update-system` scripts for supported operating systems.
- `sudo-install-perl-rename`
- `sudo-install-shiny-server`

Minor changes:

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

Major changes:

- koopa now clones Mike's dotfiles repo as a submodule, in `dotfiles/`.
- Moved install scripts from `install/` into nested inside `bin/` instead.

Minor changes:

- Reorganized exported scripts in `bin/` directory.
- Improved platform checks and related messages.
- Moved `sudo-*` scripts into nested `sudo/` directory, to allow conditional
  access in `$PATH` export for sudo users only.
- Improved `check-versions` script to determine if R is installed. Added
  additional improvements to the R code for these checks.
- Azure: `rsync-azure-files`: Now excluding `work/` directories, for bcbio.
- Initial setup of sudo scripts for RHEL 7.
- Improved information shown in `koopa-info` script.

New programs:

- `install-doom-emacs`: Setup script for doom-emacs.
- `install-genrich`: Install Genrich caller for ChIP/ATAC-seq.
- `install-python-virtualenv`: Updated to support Python 3.
- `install-rmate`: Useful utility for opening remote scripts in VS Code.
- `install-spacemacs`: Install script for spacemacs (emacs+vim editor).
- `youtube-mp3`, `youtube-thumbnail`: New `youtube-dl`-related utility scripts.

Additional files:

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

Major changes:

- Reworked activation script to use POSIX instead of bash conventions. Notably,
  this involves switching to `[` from `[[`.
- Early return using `return` instead of `exit` when koopa is already active,
  to prevent accidental lockout on a remote SSH connection.

Minor changes:

- Improved support for ZSH in activation script.
- Initial commit of `NEWS` file.
- Now checking on Travis CI only against master branch.

## koopa 0.2.3 (2019-01-01)

Minor changes:

- Improved variable quoting inside `bin/` scripts.
- Reworked activation steps in main `activate.sh` script.
- Deleted `reference.txt` file in `system/`.
- Deleted function scripts inside `functions/`. Rethinking this approach.

Removed programs:

- Deleted `sam_to_bam` utility script.

## koopa 0.2.2 (2018-12-19)

New programs:

- Added `trash` utility, which moves files to `~/.Trash`, similar to macOS.

Removed programs:

- Removed `sudo_install_git` and `sudo_install_r_cran`. Rethinking this
  approach in a future update.
- Removed these macOS-specific scripts: `brew_cleanup`, `brew_status`,
  `brew_upgrade`, `install_homebrew`, and `install_openssl`.

New functions:

- Added `path_modifiers.sh` and `quiet_which.sh` utilty functions.

Minor changes:

- Improved error message for unsupported shells in `koopa`.

## koopa 0.2.1 (2018-11-24)

New programs:

- Added `git_push_all` and `git_status_all`, corresponding to `git_pull_all`.

Minor changes:

- Improved comments regarding HISAT2 for bcbio.
- Reorganized interactive and non-interactive script handling in `system/`.
- Hardened shell scripts using `set -Eeuo pipefail`.

## koopa 0.2.0 (2018-09-23)

Now exporting new scripts in `bin/`, accessible in `$PATH`.

Major changes:

- Reworked `koopa.sh` to be exported in `bin/` as simply `koopa`.
- Reorganized activation scripts. Split out aliases into `01_aliases.sh`.
  Improved automatic activation scripts for HPC and PATH exports.
- Improved activation handling in `activate.sh`.
- Added new `info.sh` info box utility script.
- Added `list.sh` program list utility.

Minor changes:

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
- Removed "g" aliases for GitHub commands (e.g. ga, gc, gd). Too confusing.
- Simplified the separator bar for koopa message, avoiding unicode.
- Renamed `bcl2fastq_indrop` script to `bcl2fastq_indrops`.
- Added some utility scripts from macOS bash repo: `delete_fs_cruft`,
  `git_pull_all`, `gzip_dir`, `install_tex`, `move_files_up_1_level`,
  `rename_from_csv`, `reset_permissions`.

## koopa 0.1.0 (2018-08-24)

- Initial stable release.
- Repo was previously named "seqcloud".

[homebrew]: https://brew.sh/
[syntactic]: https://syntactic.acidgenomics.com/
